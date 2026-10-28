import Foundation
import AVFoundation
import MediaPlayer
import Observation

public enum RepeatMode: Int, CaseIterable {
    case off = 0
    case all = 1
    case one = 2
}

@Observable
public final class AudioPlayerManager {
    public static let shared = AudioPlayerManager()

    // MARK: - State
    public var currentSong: Song?
    public var isPlaying: Bool = false
    public var isBuffering: Bool = false
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 0
    public var isShuffle: Bool = false
    public var repeatMode: RepeatMode = .off
    public var queue: [Song] = []
    public var history: [Song] = []
    public var favoriteSongIds: Set<String> = []

    // Lyrics
    public var currentLyrics: LyricsData?
    public var currentLyricIndex: Int = 0

    // Full Player Presentation Sheet
    public var isFullPlayerPresented: Bool = false

    // MARK: - Internal Player
    private var avPlayer: AVPlayer?
    private var timeObserverToken: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?

    private init() {
        setupAudioSession()
        setupRemoteCommands()
        loadFavorites()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            print("Failed to activate AVAudioSession: \(error)")
        }
    }

    private func setupRemoteCommands() {
        NowPlayingManager.shared.setupRemoteCommands(
            onPlay: { [weak self] in self?.resume() },
            onPause: { [weak self] in self?.pause() },
            onNext: { [weak self] in self?.next() },
            onPrevious: { [weak self] in self?.previous() },
            onSeek: { [weak self] time in self?.seek(to: time) }
        )
    }

    // MARK: - Playback Control
    public func play(song: Song, newQueue: [Song]? = nil) {
        if let newQueue {
            self.queue = newQueue
        } else if !queue.contains(where: { $0.id == song.id }) {
            self.queue.append(song)
        }

        self.currentSong = song
        self.isBuffering = true
        self.currentTime = 0
        self.duration = song.duration

        // Fetch lyrics
        Task {
            let lyrics = await LrcLibAPI.shared.getLyrics(
                trackName: song.title,
                artistName: song.artistName,
                duration: song.duration
            )
            await MainActor.run {
                if self.currentSong?.id == song.id {
                    self.currentLyrics = lyrics
                    self.currentLyricIndex = 0
                }
            }
        }

        // Resolve Stream
        Task {
            let streamURL = await InnerTubeAPI.shared.resolveStream(videoId: song.videoId)
            await MainActor.run {
                guard let streamURL else {
                    self.isBuffering = false
                    return
                }
                self.startAVPlayer(url: streamURL)
            }
        }
    }

    private func startAVPlayer(url: URL) {
        cleanupPlayer()

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.avPlayer = player

        // Observer item status
        playerItemStatusObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] playerItem, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if playerItem.status == .readyToPlay {
                    self.isBuffering = false
                    let itemDuration = playerItem.duration.seconds
                    if itemDuration > 0 && !itemDuration.isNaN {
                        self.duration = itemDuration
                    }
                    self.avPlayer?.play()
                    self.isPlaying = true
                    self.updateNowPlaying()
                } else if playerItem.status == .failed {
                    self.isBuffering = false
                    self.isPlaying = false
                }
            }
        }

        // Periodic time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let secs = time.seconds
            if secs >= 0 && !secs.isNaN {
                self.currentTime = secs
                self.updateCurrentLyricIndex(time: secs)
                self.updateNowPlaying()
            }
        }

        // Item did play to end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )

        player.play()
        self.isPlaying = true
        updateNowPlaying()
    }

    @objc private func playerItemDidReachEnd() {
        if repeatMode == .one {
            seek(to: 0)
            resume()
        } else {
            next()
        }
    }

    public func pause() {
        avPlayer?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    public func resume() {
        avPlayer?.play()
        isPlaying = true
        updateNowPlaying()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    public func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        avPlayer?.seek(to: cmTime)
        currentTime = time
        updateCurrentLyricIndex(time: time)
        updateNowPlaying()
    }

    public func next() {
        guard !queue.isEmpty, let current = currentSong else { return }
        if let idx = queue.firstIndex(where: { $0.id == current.id }) {
            if isShuffle {
                let randomIdx = Int.random(in: 0..<queue.count)
                play(song: queue[randomIdx])
            } else if idx + 1 < queue.count {
                play(song: queue[idx + 1])
            } else if repeatMode == .all {
                play(song: queue[0])
            } else {
                pause()
                seek(to: 0)
            }
        } else if let first = queue.first {
            play(song: first)
        }
    }

    public func previous() {
        if currentTime > 3.0 {
            seek(to: 0)
            return
        }
        guard !queue.isEmpty, let current = currentSong else { return }
        if let idx = queue.firstIndex(where: { $0.id == current.id }) {
            if idx > 0 {
                play(song: queue[idx - 1])
            } else {
                seek(to: 0)
            }
        }
    }

    public func toggleShuffle() {
        isShuffle.toggle()
    }

    public func toggleRepeat() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    public func toggleFavorite(song: Song) {
        if favoriteSongIds.contains(song.id) {
            favoriteSongIds.remove(song.id)
        } else {
            favoriteSongIds.insert(song.id)
        }
        saveFavorites()
    }

    public func isFavorite(song: Song) -> Bool {
        favoriteSongIds.contains(song.id)
    }

    // MARK: - Lyrics Sync
    private func updateCurrentLyricIndex(time: TimeInterval) {
        guard let lyrics = currentLyrics, lyrics.isSynced, !lyrics.lines.isEmpty else { return }
        var activeIndex = 0
        for (idx, line) in lyrics.lines.enumerated() {
            if time >= line.timestamp {
                activeIndex = idx
            } else {
                break
            }
        }
        if activeIndex != currentLyricIndex {
            currentLyricIndex = activeIndex
        }
    }

    private func updateNowPlaying() {
        NowPlayingManager.shared.updateNowPlaying(
            song: currentSong,
            currentTime: currentTime,
            duration: duration,
            isPlaying: isPlaying
        )
    }

    private func cleanupPlayer() {
        if let token = timeObserverToken {
            avPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        playerItemStatusObserver?.invalidate()
        playerItemStatusObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        avPlayer?.pause()
        avPlayer = nil
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteSongIds), forKey: "kmusic_favorites")
    }

    private func loadFavorites() {
        if let ids = UserDefaults.standard.stringArray(forKey: "kmusic_favorites") {
            favoriteSongIds = Set(ids)
        }
    }
}
