//
//  ImageUploadView.swift
//  Mlem
//
//  Created by Sjmarf on 26/09/2023.
//

import Dependencies
import PhotosUI
import SwiftUI

struct LinkAttachmentModifier: ViewModifier {
    @Dependency(\.apiClient) var apiClient: APIClient
    
    @AppStorage("promptUser.permission.privacy.allowImageUploads") var askedForPermissionToUploadImages: Bool = false
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = false

    @ObservedObject var model: LinkAttachmentModel
    
    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $model.showingFilePicker, allowedContentTypes: [.image]) { result in
                model.prepareToUpload(result: result)
            }
            .photosPicker(isPresented: $model.showingPhotosPicker, selection: $model.photosPickerItem, matching: .images)
            .onChange(of: model.photosPickerItem) { newValue in
                if let newValue {
                    Task {
                        await model.prepareToUpload(photo: newValue)
                    }
                }
            }
            .onChange(of: model.url) { newValue in
                model.deletePictrs(compareUrl: newValue)
            }
            .sheet(isPresented: $model.showingUploadConfirmation) {
                UploadConfirmationView(
                    isPresented: $model.showingUploadConfirmation,
                    imageModel: $model.imageModel,
                    onUpload: model.uploadImage,
                    onCancel: { model.deletePictrs() }
                )
                .onAppear {
                    askedForPermissionToUploadImages = true
                }
            }
    }
}

extension View {
    func linkAttachmentModel(model: LinkAttachmentModel) -> some View {
        modifier(LinkAttachmentModifier(model: model))
    }
}
