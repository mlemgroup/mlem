//
//  NavigationModel.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import PhotosUI
import SwiftUI
import Translation

@Observable
class NavigationModel {
    static let main: NavigationModel = .init()
    
    private(set) var layers: [NavigationLayer] = .init()
    
    struct ShareInfo {
        let url: URL
        let activities: [ShareActivity]
        
        init(url: URL, activities: [ShareActivity]) {
            self.url = url
            self.activities = activities
        }
        
        init(url: URL, actions: [BasicAction] = []) {
            self.url = url
            self.activities = actions.compactMap { action in
                if let callback = action.callback {
                    .init(appearance: action.appearance, performAction: callback)
                } else {
                    nil
                }
            }
        }
    }

    @Observable
    class ContentPickerTracker {
        var photosPickerCallback: ((PhotosPickerItem) -> Void)?
        
        // This needs two values unlike `photosPickerCallback` because
        // `fileImporter` sets `isPresented` to `false` before calling
        // `onCompletion`, which makes it impossible to call the callback
        // before setting it to `nil`.
        var showingFilePicker: Bool = false
        var filePickerCallback: ((URL) -> Void)?
        var filePickerContentTypes: [UTType] = []
    }
    
    var contentPickerTracker: ContentPickerTracker = .init()
    
    var mediaUrl: URL?
    var shareInfo: ShareInfo?
    var pendingOpenURL: URL?

    var translationConfiguration: TranslationConfiguration = .init()

    @MainActor
    private func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil, isFullScreenCover: Bool) {
        guard Thread.isMainThread else {
            assertionFailure()
            ToastModel.main.add(.failure("Failed to open sheet"))
            return
        }
        
        layers.append(
            .init(
                root: page,
                model: self,
                index: layers.count,
                hasNavigationStack: hasNavigationStack ?? page.hasNavigationStack,
                isFullScreenCover: isFullScreenCover,
                canDisplayToasts: page.canDisplayToasts
            )
        )
    }
    
    // Closes all sheets above and including the given index
    @MainActor
    func closeSheets(aboveIndex index: Int) {
        for layer in layers.dropFirst(index) {
            layer.model = nil
        }
        layers.removeLast(max(0, layers.count - index))
    }
    
    @MainActor
    func clear() {
        layers.forEach { $0.model = nil }
        layers = []
    }
    
    @MainActor
    func openSheet(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: false)
    }
    
    @MainActor
    func showFullScreenCover(_ page: NavigationPage, hasNavigationStack: Bool? = nil) {
        openSheet(page, hasNavigationStack: hasNavigationStack, isFullScreenCover: true)
    }
}

struct TranslationConfiguration {
    var sessionConfig: TranslationSession.Configuration?
    var presentationNeeded: Bool = false
}
