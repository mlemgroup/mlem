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
    @ViewBuilder let label: () -> Label
    
    init(imageManager: ImageUploadManager, imageUploadApi: ApiClient, @ViewBuilder label: @escaping () -> Label) {
        self.imageManager = imageManager
        self.imageUploadApi = imageUploadApi
        self.label = label
    }
    
    var body: some View {
        Menu(content: {
            Button("Photo Library", icon: .general.chooseImage) {
                navigation.showPhotosPicker(for: imageManager, api: imageUploadApi)
            }
            Button("Choose File", icon: .general.chooseFile) {
                navigation.showFilePicker(for: imageManager, api: imageUploadApi)
            }
            Button("Paste", icon: .general.paste) {
                navigation.uploadImageFromClipboard(for: imageManager, api: imageUploadApi)
            }
        }, label: label)
            .disabled(imageManager.state != .idle)
    }
}
