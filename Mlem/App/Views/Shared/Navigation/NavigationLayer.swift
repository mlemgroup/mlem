//
//  NavigationLayer.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class NavigationLayer {
    struct ShareInfo {
        let url: URL
        let activities: [ShareActivity]
        
        init(url: URL, activities: [ShareActivity] = []) {
            self.url = url
            self.activities = activities
        }
        
        init(_ action: ShareAction) {
            self.url = action.url
            self.activities = action.actions.compactMap { action in
                if let callback = action.callback {
                    .init(appearance: action.appearance, performAction: callback)
                } else {
                    nil
                }
            }
        }
    }
    
    weak var model: NavigationModel?
    var index: Int
    
    var root: NavigationPage
    var path: [NavigationPage]
    var shareInfo: ShareInfo?
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
    
    func push(_ page: NavigationPage) {
        if hasNavigationStack {
            path.append(page)
        } else {
            openSheet(page)
        }
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
        if path.isEmpty, index != -1 {
            model?.closeSheets(aboveIndex: index)
        }
    }
    
    func dismissSheet() {
        model?.closeSheets(aboveIndex: index)
    }
    
    var isTopSheet: Bool {
        isInsideSheet && index == (model?.layers.count ?? 0) - 1
    }
    
    var isToastDisplayer: Bool {
        isInsideSheet
            && canDisplayToasts
            && model?.layers.last(where: { $0.canDisplayToasts }) === self
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.openSheet(
            page,
            hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
        )
    }
    
    /// Open a new sheet, optionally with navigation enabled. If `nil` is specified for `hasNavigationStack`, the value of `page.hasNavigationStack` will be used.
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        model?.showFullScreenCover(
            page,
            hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack
        )
    }
    
    func showPhotosPicker(for imageUploadManager: ImageUploadManager, api: ApiClient) {
        model?.photosPickerCallback = { photo in
            Task {
                do {
                    guard let data = try await photo.loadTransferable(type: Data.self) else {
                        throw ApiClientError.unsuccessful
                    }
                    if Settings.main.confirmImageUploads {
                        self.openSheet(.confirmUpload(imageData: data, imageManager: imageUploadManager, uploadApi: api))
                    } else {
                        try await imageUploadManager.upload(data: data, api: api)
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    func showFilePicker(for imageUploadManager: ImageUploadManager, api: ApiClient) {
        model?.showingFilePicker = true
        model?.filePickerCallback = { url in
            Task {
                do {
                    guard url.startAccessingSecurityScopedResource() else {
                        throw ApiClientError.insufficientPermissions
                    }
                    let data = try Data(contentsOf: url)
                    url.stopAccessingSecurityScopedResource()
                    if Settings.main.confirmImageUploads {
                        self.openSheet(.confirmUpload(imageData: data, imageManager: imageUploadManager, uploadApi: api))
                    } else {
                        try await imageUploadManager.upload(data: data, api: api)
                    }
                } catch {
                    url.stopAccessingSecurityScopedResource()
                    handleError(error)
                }
            }
        }
    }
    
    func uploadImageFromClipboard(for imageUploadManager: ImageUploadManager, api: ApiClient) {
        Task {
            do {
                if UIPasteboard.general.hasImages, let content = UIPasteboard.general.image {
                    if let data = content.pngData() {
                        if Settings.main.confirmImageUploads {
                            self.openSheet(.confirmUpload(imageData: data, imageManager: imageUploadManager, uploadApi: api))
                        } else {
                            try await imageUploadManager.upload(data: data, api: api)
                        }
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    var isInsideSheet: Bool { index != -1 }
    
    // Can be used inside of an `.onDisappear` to determine whether the disappearance was caused by the sheet closing
    var isAlive: Bool { model != nil }
}
