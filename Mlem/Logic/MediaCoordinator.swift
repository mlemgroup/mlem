//
//  MediaCoordinator.swift
//  Mlem
//
//  Created by tht7 on 01/09/2023.
//

import Foundation
import SwiftUI
import UIKit
import Nuke
import NukeVideo
import NukeUI
import SwiftyGif
import AVKit
import Combine
import LinkPresentation
import VisionKit
import Photos

let analyzer = ImageAnalyzer()

// swiftlint:disable type_body_length
class MediaCoordinator<ErrorView: View>: NSObject, UIActivityItemSource {

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        ""
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        linkMeta
    }

    var errorView = UIHostingController(rootView: AnyView(EmptyView()))
    var imageContainer: ImageContainer?
    var onImageLoad: ((_: ImageContainer, _ size: CGSize) -> Void)?

    var parent: CoreMediaViewer<ErrorView>?
    var imageView = LazyImageView()
    var wasReady: Bool = false

    var shareableImage: UIImage?
    var linkMeta: LPLinkMetadata?

    var gifObserver: Timer? //: NSKeyValueObservation?

    var gifView: UIImageView?
    var videoPlayerView: VideoPlayerView?

    // all the silliy listeners
    var listeners: [AnyCancellable] = .init()
    var editingListener: AnyCancellable = .init({})

    var mediaSize: CGSize = .zero

    // super evil hack for swiftGif, smapling the currentFrame out of sync (which we have no access to the sync variable, f-ing private)
    // results in the last frame you seeked to (so 0 by default) which makes the bar all jumpy and unpleasent
    // sooooo I can ignore that frame
    var evilFrame: Int = 0
    var lastFrame: Int = 0

    private var timeObserver: Any?
    private var statusObserver: Any?

    init(parent: CoreMediaViewer<ErrorView>, onImageLoad: ((_: ImageContainer, _ size: CGSize) -> Void)?) {
        self.parent = parent
        self.onImageLoad = onImageLoad

    }

    @MainActor
    func resetValues() {
        errorView = UIHostingController(rootView: AnyView(EmptyView()))
        imageContainer = nil
        onImageLoad = nil
        
        imageView.failureView = nil
        imageView.makeImageView = nil
        imageView.onFailure = nil
        
        parent = nil
        wasReady = false
        
        shareableImage = nil
        linkMeta = nil
        
        // NSKeyValueObservation will be invaildated automaticlly when de-init
        gifObserver?.invalidate()
        gifObserver = nil
        
        gifView = nil
        videoPlayerView = nil
        
        listeners.removeAll()
        editingListener.cancel()
        editingListener = .init({})
        
        mediaSize = .zero
        
        evilFrame = 0
        lastFrame = 0
        
        timeObserver = nil
        statusObserver = nil
    }

    // swiftlint:disable function_body_length
    func generateContextMenu() -> [MenuFunction] {
        var menuItems: [MenuFunction] = []

        let shareLink = MenuFunction(
            text: "Share Link",
            imageName: "square.and.arrow.up",
            destructiveActionPrompt: nil,
            enabled: true) {
                self.linkMeta = LPLinkMetadata()
                if let placeholder = self.imageContainer?.image {
                    self.linkMeta?.imageProvider = NSItemProvider(object: placeholder)
                }
                self.linkMeta?.url = self.parent?.url
                showShareSheet(items: [self.parent?.url as Any, self])
            }
        menuItems.append(shareLink)

        if let container = imageContainer {
            if container.image.size != .zero || self.gifView != nil {
                let regualarShare = MenuFunction(
                    text: "Share Image",
                    imageName: "photo",
                    destructiveActionPrompt: nil,
                    enabled: true) {
                        self.linkMeta = LPLinkMetadata()
                        self.linkMeta?.imageProvider = NSItemProvider(object: container.image)
                        self.linkMeta?.url = self.parent?.url
                        if let data = container.data {
                            showShareSheet(items: [data, self])
                        } else {
                            showShareSheet(items: [container.image, self])
                        }
                    }
                menuItems.append(regualarShare)

                let saveImage = MenuFunction(
                    text: "Save Image",
                    imageName: "square.and.arrow.down",
                    destructiveActionPrompt: nil,
                    enabled: true) {
                        if self.gifView != nil, let data = self.imageContainer?.data {
                            PHPhotoLibrary.shared().performChanges {
                                let request: PHAssetCreationRequest = .forAsset()
                                request.addResource(with: .photo, data: data, options: PHAssetResourceCreationOptions())
                                
                            } completionHandler: { _, _ in
                            }
                        } else {
                        UIImageWriteToSavedPhotosAlbum(container.image, nil, nil, nil)
                        }
                    }
                menuItems.append(saveImage)
            }

            if let gifImage = self.gifView {
                let shareCurrntFrameGif = MenuFunction(
                    text: "Share current Frame",
                    imageName: "photo",
                    destructiveActionPrompt: nil,
                    enabled: true) {
                        self.linkMeta = LPLinkMetadata()
                        self.linkMeta?.imageProvider = NSItemProvider(object: gifImage.currentImage!)
                        self.linkMeta?.url = self.parent?.url
                        showShareSheet(items: [gifImage.currentImage as Any, self])
                    }
                menuItems.append(shareCurrntFrameGif)
            }
        }
        return menuItems
    }
    // swiftlint:enable function_body_length

    @MainActor
    func makeImage(container: ImageContainer) -> _PlatformBaseView {
        defer {
            Task { @MainActor in
                imageView.invalidateIntrinsicContentSize()
                imageView.setNeedsLayout()
                let needsMediaSync = (parent?.needsMediaSync ?? false)
                if let type = container.type, needsMediaSync {
                    self.parent?.mediaStateSyncObject.type = type
                }
                self.imageContainer = container
                if needsMediaSync {
                    self.parent?.mediaStateSyncObject.isReady = true
                }
                if !(container.type?.isVideo ?? false) {
                    if let onImageLoad = onImageLoad {
                        onImageLoad(container, self.mediaSize)
                    }
                }
            }
        }
        //        mediaStateSyncObject.type = container.type ?? .jpeg
        if container.type == .gif, let data = container.data {
            return initializeGIF(container: container, data: data)
        } else if
            let type = container.type, type.isVideo, let asset = container.userInfo[.videoAssetKey] as? AVAsset {
            return initializePlayer(container: container, asset: asset)
        } else {
            self.mediaSize = container.image.size
            let uiimageView = UIImageView(image: container.image)
            uiimageView.contentMode = .scaleAspectFit
            if parent?.needsMediaSync ?? false {
                let interaction = ImageAnalysisInteraction()
                uiimageView.addInteraction(interaction)
                interaction.preferredInteractionTypes = .automatic
                interaction.allowLongPressForDataDetectorsInTextMode = true
                interaction.setSupplementaryInterfaceHidden(false, animated: true)
                Task { @MainActor in
                    let analysis = try? await analyzer.analyze(
                        container.image,
                        configuration: ImageAnalyzer.Configuration([.text, .machineReadableCode, .visualLookUp])
                    )
                    interaction.analysis = analysis
                }
            }
            
            return uiimageView
        }
    }

    // swiftlint:disable function_body_length
    @MainActor
    func initializePlayer(container: ImageContainer, asset: AVAsset) -> _PlatformBaseView {
        videoPlayerView = VideoPlayerView()
        videoPlayerView!.animatesFrameChanges = false
        videoPlayerView!.asset = asset
        videoPlayerView!.play()
        videoPlayerView!.videoGravity = .resizeAspect
        videoPlayerView!.contentMode = .scaleAspectFit

        statusObserver = videoPlayerView?.playerLayer.player?.observe(\.status, options: [.new, .initial]) { player, _ in
            if player.status == .readyToPlay {
                Task { @MainActor in
                    let (size, duration) = await asset.getTrackDetails() ?? (.zero, .zero)
                    if self.parent?.needsMediaSync ?? false {
                        // Invoke callback every second
                        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                        
                        // Keep the reference to remove
                        self.timeObserver = player.addPeriodicTimeObserver(forInterval: interval,
                                                                           queue: DispatchQueue.main) { time in
                            self.parent?.mediaStateSyncObject.currentTime =  time.seconds
                        }
                        self.parent?.mediaStateSyncObject.duration = duration.seconds
                        self.parent?.mediaStateSyncObject.player = player
                        self.parent?.mediaStateSyncObject.isReady = true
                    }
                    
                    self.mediaSize = size
                    if let onImageLoad = self.onImageLoad {
                        onImageLoad(container, size)
                    }
                }
            }
        }
        
        if self.parent?.needsMediaSync ?? false {
            self.parent?.mediaStateSyncObject.$isPlaying.sink { newVal in
                Task(priority: .userInitiated) {
                    if let videoPlayerView = self.videoPlayerView {
                        if newVal {
                            videoPlayerView.playerLayer.player?.play()
                        } else {
                            videoPlayerView.playerLayer.player?.pause()
                        }
                    }
                }
            }.store(in: &listeners)
            
            self.parent?.mediaStateSyncObject.$isEditingCurrentTime.sink { editMode in
                if editMode {
                    // now entering edit mode!
                    self.editingListener = self.parent?.mediaStateSyncObject.$currentTime.sink { newTime in
                        let time = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                        self.videoPlayerView?.playerLayer.player?.seek(to: time)
                    } ?? .init({})
                } else {
                    // now leaving edit mode!
                    self.editingListener.cancel()
                }
            }.store(in: &listeners)
        }

        return videoPlayerView!
    }
    // swiftlint:enable function_body_length
    func initializeGIF(container: ImageContainer, data: Data) -> _PlatformBaseView {
        gifView = UIImageView(gifImage: container.image)
        // TODO: move this line into Nuke so decoding can happen in a different thread
        self.mediaSize = (container.userInfo["size"] as? CGSize) ?? container.image.size
        
        gifView!.contentMode = .scaleAspectFit
        gifView!.translatesAutoresizingMaskIntoConstraints = true
        
        if parent?.needsMediaSync ?? false {
            
            gifObserver = Timer.scheduledTimer(
                withTimeInterval: 1 / 100,
                repeats: true
            ) { [weak self] _ in
                guard let self = self else { return }
                let currentFrame = self.gifView!.currentFrameIndex()
                if currentFrame != self.evilFrame && 
                    !(self.parent?.mediaStateSyncObject.isEditingCurrentTime ?? false) &&
                    (self.parent?.needsMediaSync ?? false) {
                    self.parent?.mediaStateSyncObject.currentTime = Double(currentFrame)
                }
            }
                
            self.parent?.mediaStateSyncObject.duration = Double(gifView!.gifImage!.framesCount())
            
            self.parent?.mediaStateSyncObject.$isPlaying.sink { [weak self] newVal in
                if let gifView = self?.gifView {
                    if newVal {
                        gifView.startAnimatingGif()
                    } else {
                        gifView.stopAnimatingGif()
                    }
                }
            }
            .store(in: &listeners)
            
            self.parent?.mediaStateSyncObject.$isEditingCurrentTime.sink { editMode in
                if editMode {
                    // now entering edit mode!
                    self.editingListener = self.parent?.mediaStateSyncObject.$currentTime.sink { newTime in
                        self.evilFrame = max(0, Int(newTime) % self.gifView!.gifImage!.framesCount())
                        self.gifView!.showFrameAtIndex(self.evilFrame)
                    } ?? .init({})
                } else {
                    // now leaving edit mode!
                    self.editingListener.cancel()
                }
            }.store(in: &listeners)
        }

        return gifView!
    }
    
    deinit {
        print("MediaCoo DEINIT")
    }
}
// swiftlint:enable type_body_length
extension AVAsset {
    func getTrackDetails() async -> (CGSize, CMTime)? {
        guard let tracks = try? await loadTracks(withMediaType: .video) else { return nil }
        guard let track = tracks.first else { return nil }
        guard let size = try? await track.load(.naturalSize) else { return nil }
        guard let duration = try? await load(.duration) else { return nil }
        return (size, duration)
    }
}
