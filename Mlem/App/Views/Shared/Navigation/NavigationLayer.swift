//
//  NavigationLayer.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import MlemMiddleware
import SwiftUI
import UniformTypeIdentifiers

@Observable
class NavigationLayer: Identifiable {
    var id: ObjectIdentifier { .init(self) }
    
    weak var model: NavigationModel?
    var index: Int
    
    var root: NavigationPage
    var path: [NavigationPage]
    var hasNavigationStack: Bool
    var isFullScreenCover: Bool
    var canDisplayToasts: Bool
    
    init(
        root: NavigationPage,
        path: [NavigationPage] = [],
        model: NavigationModel,
        index: Int = -1,
        hasNavigationStack: Bool = true,
        isFullScreenCover: Bool = false,
        canDisplayToasts: Bool = true
    ) {
        self.model = model
        self.index = index
        self.root = root
        self.path = path
        self.hasNavigationStack = hasNavigationStack
        self.isFullScreenCover = isFullScreenCover
        self.canDisplayToasts = canDisplayToasts
    }
    
    @MainActor
    func push(_ page: NavigationPage) {
        if hasNavigationStack {
            // This prevents keyboard animation glitches when navigating whilst the keyboard is open
            UIApplication.shared.firstKeyWindow?.endEditing(true)
            path.append(page)
        } else {
            openSheet(page)
        }
    }

    @MainActor
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
        if path.isEmpty, index != -1 {
            model?.closeSheets(aboveIndex: index)
        }
    }
    
    @MainActor
    func dismissSheet() {
        model?.closeSheets(aboveIndex: index)
    }
    
    var isTopSheet: Bool {
        isInsideSheet && index == (model?.layers.count ?? 0) - 1
    }
    
    var isBottomLayer: Bool { index == -1 }
    
    var isToastDisplayer: Bool {
        isInsideSheet
            && canDisplayToasts
            && model?.layers.last(where: { $0.canDisplayToasts }) === self
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    var isAtRoot: Bool { path.isEmpty }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    @MainActor
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.openSheet(
            page,
            hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
        )
    }
    
    /// Convenience proxy for showFullScreenCover. Opens the image viewer with the given URL and disables animations on the fullScreenCover.
    @MainActor
    func showImageViewer(url: URL) {
        withoutAnimation {
            self.showFullScreenCover(.imageViewer(url), hasNavigationStack: false)
        }
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    @MainActor
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.showFullScreenCover(
            page,
            hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
        )
    }
    
    @MainActor
    func showPhotosPicker(for imageUploadManager: ImageUploadManager, api: ApiClient) {
        model?.contentPickerTracker.photosPickerCallback = { photo in
            Task {
                do {
                    guard let data = try await photo.loadTransferable(type: Data.self) else {
                        throw ApiClientError.unsuccessful
                    }
                    guard let fileExtension = photo.supportedContentTypes.first?.preferredFilenameExtension else {
                        throw ApiClientError.unsuccessful
                    }
                    if Settings.get(\.behavior_confirmImageUploads) {
                        self.openSheet(.confirmUpload(
                            imageData: data,
                            fileExtension: fileExtension,
                            imageManager: imageUploadManager,
                            uploadApi: api
                        ))
                    } else {
                        try await imageUploadManager.upload(data: data, fileExtension: fileExtension, api: api)
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    @MainActor
    func showFilePicker(for imageUploadManager: ImageUploadManager, api: ApiClient) {
        model?.contentPickerTracker.showingFilePicker = true
        model?.contentPickerTracker.filePickerContentTypes = [.image]
        model?.contentPickerTracker.filePickerCallback = { url in
            Task {
                do {
                    guard url.startAccessingSecurityScopedResource() else {
                        throw MlemError.cannotAccessSecurityScopedResource
                    }
                    let data = try Data(contentsOf: url)
                    url.stopAccessingSecurityScopedResource()
                    if Settings.get(\.behavior_confirmImageUploads) {
                        self.openSheet(.confirmUpload(
                            imageData: data,
                            fileExtension: url.pathExtension,
                            imageManager: imageUploadManager,
                            uploadApi: api
                        ))
                    } else {
                        try await imageUploadManager.upload(data: data, fileExtension: url.pathExtension, api: api)
                    }
                } catch {
                    url.stopAccessingSecurityScopedResource()
                    handleError(error)
                }
            }
        }
    }
    
    @MainActor
    func showFilePicker(types: [UTType], callback: @escaping (Data) async -> Void) {
        model?.contentPickerTracker.showingFilePicker = true
        model?.contentPickerTracker.filePickerContentTypes = types
        model?.contentPickerTracker.filePickerCallback = { url in
            Task {
                do {
                    guard url.startAccessingSecurityScopedResource() else {
                        throw MlemError.cannotAccessSecurityScopedResource
                    }
                    let data = try Data(contentsOf: url)
                    await callback(data)
                    url.stopAccessingSecurityScopedResource()
                } catch {
                    url.stopAccessingSecurityScopedResource()
                    handleError(error)
                }
            }
        }
    }
    
    @MainActor
    func uploadImageFromClipboard(for imageUploadManager: ImageUploadManager, api: ApiClient) {
        if UIPasteboard.general.hasImages, let content = UIPasteboard.general.image {
            if let data = content.pngData() {
                if Settings.get(\.behavior_confirmImageUploads) {
                    openSheet(.confirmUpload(
                        imageData: data,
                        fileExtension: "png",
                        imageManager: imageUploadManager,
                        uploadApi: api
                    ))
                } else {
                    Task {
                        do {
                            try await imageUploadManager.upload(data: data, fileExtension: "png", api: api)
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
        }
    }
    
    var isInsideSheet: Bool { index != -1 }
    
    // Can be used inside of an `.onDisappear` to determine whether the disappearance was caused by the sheet closing
    var isAlive: Bool { model != nil }
    
    var isImageViewer: Bool {
        switch root {
        case .imageViewer: true
        default: false
        }
    }
}
