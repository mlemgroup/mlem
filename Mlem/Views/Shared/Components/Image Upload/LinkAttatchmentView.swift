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
    
    @ViewBuilder let content: (LinkAttachmentProxy) -> Content
    @StateObject private var model: LinkAttachmentModel
    
    @Binding var url: String
    
    init(
        url: Binding<String>,
        imageModel: Binding<PictrsImageModel?> = .constant(nil),
        @ViewBuilder content: @escaping (LinkAttachmentProxy) -> Content
    ) {
        @AppStorage("promptUser.permission.privacy.allowImageUploads") var askedForPermissionToUploadImages: Bool = false
        @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = false
        self._url = url
        self.content = content
        self._model = StateObject(wrappedValue: LinkAttachmentModel(
            url: url,
            imageModel: imageModel,
            askedForPermissionToUploadImages: $askedForPermissionToUploadImages,
            confirmImageUploads: $confirmImageUploads
        ))
    }
    
    var body: some View {
        content(LinkAttachmentProxy(model: self.model))
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
            .onChange(of: url) { newValue in
                model.deletePictrs(compareUrl: newValue)
            }
            .sheet(isPresented: $model.showingUploadConfirmation) {
                UploadConfirmationView(
                    isPresented: $model.showingUploadConfirmation,
                    onUpload: model.uploadImage,
                    onCancel: { model.deletePictrs() },
                    imageModel: model.imageModel
                )
                .interactiveDismissDisabled()
                .onAppear {
                    askedForPermissionToUploadImages = true
                }
            }
    }
}
