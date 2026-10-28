import Foundation
import MediaPlayer
import UIKit

@MainActor
public final class NowPlayingManager {
    public static let shared = NowPlayingManager()

    private init() {}

    public func updateNowPlaying(song: Song?, currentTime: TimeInterval, duration: TimeInterval, isPlaying: Bool) {
        guard let song else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artistName,
            MPMediaItemPropertyPlaybackDuration: duration > 0 ? duration : song.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let album = song.albumName {
            info[MPMediaItemPropertyAlbumTitle] = album
        }

        if let thumbURL = song.thumbnailURL {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: thumbURL),
                   let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    var currentInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                    currentInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = currentInfo
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    public func setupRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onSeek: @escaping (TimeInterval) -> Void
    ) {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            onPlay()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            onPause()
            return .success
        }

        commandCenter.togglePlayPauseMusicCommand.isEnabled = true
        commandCenter.togglePlayPauseMusicCommand.addTarget { _ in
            onPlay()
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { _ in
            onNext()
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { _ in
            onPrevious()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                onSeek(positionEvent.positionTime)
                return .success
            }
            return .commandFailed
        }
    }
}
