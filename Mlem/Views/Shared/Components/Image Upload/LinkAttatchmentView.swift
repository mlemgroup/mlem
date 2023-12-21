//
//  ImageUploadView.swift
//  Mlem
//
//  Created by Sjmarf on 26/09/2023.
//

import SwiftUI
import PhotosUI
import Dependencies

struct LinkAttachmentView<Content: View>: View {
    @Dependency(\.apiClient) var apiClient: APIClient
    
    @AppStorage("promptUser.permission.privacy.allowImageUploads") var askedForPermissionToUploadImages: Bool = false
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = false
    
    @ViewBuilder let content: Content

    @ObservedObject var model: LinkAttachmentModel
    
    init(
        model: LinkAttachmentModel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        self.model = model
    }
    
    var body: some View {
        content
            .photosPicker(isPresented: $model.showingPhotosPicker, selection: $model.photosPickerItem, matching: .images)
            .fileImporter(isPresented: $model.showingFilePicker, allowedContentTypes: [.image]) { result in
                model.prepareToUpload(result: result)
            }
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
