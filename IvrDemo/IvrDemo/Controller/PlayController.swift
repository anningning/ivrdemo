//
//  PlayController.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
// 播放逻辑管理器

import Foundation
import AVKit
import GroupActivities
import Combine
import Observation

/// 播放模式
enum PlayerModel {
    /// 默认 预告片模式
    case inline
    
    /// 普通2d 3d视频
    case fullWindow
    
    /// 全景视频
    case fullPanoSpace
}

@Observable class PlayController {
    
    /// A Boolean value that indicates whether playback is currently active.
    private(set) var isPlaying = false
    
    /// A Boolean value that indicates whether playback of the current item is complete.
    private(set) var isPlaybackComplete = false
    
    /// 播放模式
    private(set) var playModel: PlayerModel = .inline
    
    /// The currently loaded video.
    private(set) var currentItem: VideoInfo? = nil

    
    /// An object that manages the playback of a video's media.
    public var player = AVPlayer()
    
    /// The currently presented player view controller.
    ///
    /// The life cycle of an `AVPlayerViewController` object is different than a typical view controller. In addition
    /// to displaying the player UI within your app, the view controller also manages the presentation of the media
    /// outside your app UI such as when using AirPlay, Picture in Picture, or docked full window. To ensure the view
    /// controller instance is preserved in these cases, the app stores a reference to it here (which
    /// is an environment-scoped object).
    ///
    /// This value is set by a call to the `makePlayerViewController()` method.
    private var playerViewController: AVPlayerViewController? = nil
    private var playerViewControllerDelegate: AVPlayerViewControllerDelegate? = nil
    
    private(set) var shouldAutoPlay = true
    
    
    /// A token for periodic observation of the player's time.
    private var timeObserver: Any? = nil
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        observePlayback()
        Task {
            await configureAudioSession()
        }
    }
    
    /// Creates a new player view controller object.
    /// - Returns: a configured player view controller.
    func makePlayerViewController() -> AVPlayerViewController {
        let delegate = PlayerViewControllerDelegate(player: self)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.delegate = delegate

        // Set the model state
        playerViewController = controller
        playerViewControllerDelegate = delegate
        
        return controller
    }
    
    private func observePlayback() {
        // Return early if the model calls this more than once.
        guard subscriptions.isEmpty else { return }
        
        // Observe the time control status to determine whether playback is active.
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] status in
                self?.isPlaying = status == .playing
            }
            .store(in: &subscriptions)
        
        // Observe this notification to know when a video plays to its end.
        NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .map { _ in true }
            .sink { [weak self] isPlaybackComplete in
                self?.isPlaybackComplete = isPlaybackComplete
            }
            .store(in: &subscriptions)
        
        // Observe audio session interruptions.
        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                
                // Wrap the notification in helper type that extracts the interruption type and options.
                guard let result = InterruptionResult(notification) else { return }
                
                // Resume playback, if appropriate.
                if result.type == .ended && result.options == .shouldResume {
                    self?.player.play()
                }
            }.store(in: &subscriptions)
        
        // Add an observer of the player object's current time. The app observes
        // the player's current time to determine when to propose playing the next
        // video in the Up Next list.
        addTimeObserver()
    }
    
    /// Configures the audio session for video playback.
    private func configureAudioSession() async {
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for playback. Set the `moviePlayback` mode
            // to reduce the audio's dynamic range to help normalize audio levels.
            try session.setCategory(.playback, mode: .moviePlayback)
        } catch {
            logger.error("Unable to configure audio session: \(error.localizedDescription)")
        }
    }

    
    /// Loads a video for playback in the requested presentation.
    /// - Parameters:
    ///   - video: The video to load for playback.
    ///   - presentation: The style in which to present the player.
    ///   - autoplay: A Boolean value that indicates whether to auto play that the content when presented.
    func prepareVideo(_ video: VideoInfo, playmodel: PlayerModel = .inline, autoplay: Bool = true) {
        // Update the model state for the request.
        currentItem = video
        shouldAutoPlay = autoplay
        isPlaybackComplete = false
        
        switch playmodel {
        case .fullWindow:
            Task { @MainActor in
                // After preparing for coordination, load the video into the player and present it.
                replaceCurrentItem(with: video)
            }
        case .inline, .fullPanoSpace:
            // Don't SharePlay the video the when playing it from the inline player,
            // load the video into the player and present it.
            replaceCurrentItem(with: video)
        }

        // In visionOS, configure the spatial experience for either .inline or .fullWindow playback.
        configureAudioExperience(for: playmodel)

        setPlayModel(playmodel)
   }

    //设置播放类型
    func setPlayModel(_ model: PlayerModel){
        self.playModel = model
    }
    
    private func replaceCurrentItem(with video: VideoInfo) {
        
        // Create a new player item and set it as the player's current item.
        let playerItem = AVPlayerItem(url: video.resolvedURL)
        // Set external metadata on the player item for the current video.
        playerItem.externalMetadata = createMetadataItems(for: video)
        // Set the new player item as current, and begin loading its data.
        player.replaceCurrentItem(with: playerItem)
        logger.debug("🍿 \(video.title) enqueued for playback.")
    }
    
    /// Clears any loaded media and resets the player model to its default state.
    func reset() {
        currentItem = nil
        player.replaceCurrentItem(with: nil)
        playerViewController = nil
        playerViewControllerDelegate = nil
        // Reset the presentation state on the next cycle of the run loop.
        Task { @MainActor in
            playModel = .inline
        }
    }
    
    /// Creates metadata items from the video items data.
    /// - Parameter video: the video to create metadata for.
    /// - Returns: An array of `AVMetadataItem` to set on a player item.
    private func createMetadataItems(for video: VideoInfo) -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: video.title,
            .commonIdentifierArtwork: video.imageData,
            .commonIdentifierDescription: video.description,
            .commonIdentifierCreationDate: video.info.releaseDate,
            .iTunesMetadataContentRating: video.info.contentRating,
            .quickTimeMetadataGenre: video.info.features
        ]
        return mapping.compactMap { createMetadataItem(for: $0, value: $1) }
    }
    
    /// Creates a metadata item for a the specified identifier and value.
    /// - Parameters:
    ///   - identifier: an identifier for the item.
    ///   - value: a value to associate with the item.
    /// - Returns: a new `AVMetadataItem` object.
    private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
    
    /// Configures the user's intended spatial audio experience to best fit the presentation.
    /// - Parameter presentation: the requested player presentation.
    private func configureAudioExperience(for presentation: PlayerModel) {
        do {
            let experience: AVAudioSessionSpatialExperience
            switch presentation {
            case .inline:
                // Set a small, focused sound stage when watching trailers.
                experience = .headTracked(soundStageSize: .small, anchoringStrategy: .automatic)
            default:
                // Set a large sound stage size when viewing full window.
                experience = .headTracked(soundStageSize: .large, anchoringStrategy: .automatic)
            }
            try AVAudioSession.sharedInstance().setIntendedSpatialExperience(experience)
        } catch {
            logger.error("Unable to set the intended spatial experience. \(error.localizedDescription)")
        }
    }

    // MARK: - Transport Control
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayback() {
        player.timeControlStatus == .paused ? play() : pause()
    }
    
    // MARK: - Time Observation
    private func addTimeObserver() {
        removeTimeObserver()
        // Observe the player's timing every 1 second
        let timeInterval = CMTime(value: 1, timescale: 1)
        timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration else { return }
            // Propose playing the next episode within 10 seconds of the end of the current episode.
            let isInProposalRange = time.seconds >= duration.seconds - 10.0
        }
    }
    
    private func removeTimeObserver() {
        guard let timeObserver = timeObserver else { return }
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }
    
    /// A coordinator that acts as the player view controller's delegate object.
    final class PlayerViewControllerDelegate: NSObject, AVPlayerViewControllerDelegate {
        
        let player: PlayController
        
        init(player: PlayController) {
            self.player = player
        }
        
        // The app adopts this method to reset the state of the player model when a user
        // taps the back button in the visionOS player UI.
        func playerViewController(_ playerViewController: AVPlayerViewController,
                                  willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            Task { @MainActor in
                // Calling reset dismisses the full-window player.
                player.reset()
            }
        }
    }
}
