//
//  ImageUploadMenu.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-04.
//

import MlemMiddleware
import SwiftUI

struct ImageUploadMenu<Label: View>: View {
    @Environment(NavigationLayer.self) var navigation

    let imageManager: ImageUploadManager
    let imageUploadApi: ApiClient
    let triggerUpload: Bool
    @ViewBuilder let label: () -> Label
    
    init(
        imageManager: ImageUploadManager,
        imageUploadApi: ApiClient,
        triggerUpload: Bool,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.imageManager = imageManager
        self.imageUploadApi = imageUploadApi
        self.triggerUpload = triggerUpload
        self.label = label
    }
    
    var body: some View {
        Menu(content: {
            Button("Photo Library", icon: .general.chooseImage) {
                navigation.showPhotosPicker(for: imageManager, api: imageUploadApi) {
                    try await upload()
                }
            }
            Button("Choose File", icon: .general.chooseFile) {
                navigation.showFilePicker(for: imageManager, api: imageUploadApi) {
                    try await upload()
                }
            }
            Button("Paste", icon: .general.paste) {
                Task {
                    await imageManager.pasteFromClipboard()
                    do {
                        try await upload()
                    } catch {
                        handleError(error)
                    }
                }
            }
        }, label: label)
            .disabled(imageManager.state != .idle)
    }

    func upload() async throws {
        if triggerUpload {
            try await navigation.triggerUpload(for: imageManager, api: imageUploadApi)
        }
    }
}
