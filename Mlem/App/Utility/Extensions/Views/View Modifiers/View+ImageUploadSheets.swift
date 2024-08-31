//
//  View+ImageUploadSheets.swift
//  Mlem
//
//  Created by Sjmarf on 31/08/2024.
//

import MlemMiddleware
import PhotosUI
import SwiftUI

enum ImageUploadPresentationState {
    case photos, files
}

private struct ImageUploadSheetsModifier: ViewModifier {
    let api: ApiClient
    let callback: (ImageUpload1) -> Void
    @Binding var presentationState: ImageUploadPresentationState?
    
    @State private var photoSelection: PhotosPickerItem?
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: .init(
                    get: { presentationState == .photos },
                    set: { presentationState = $0 ? .photos : nil }
                ),
                selection: $photoSelection,
                matching: .images
            )
            .fileImporter(
                isPresented: .init(
                    get: { presentationState == .files },
                    set: { presentationState = $0 ? .files : nil }
                ),
                allowedContentTypes: [.image],
                onCompletion: { result in
                    Task {
                        do {
                            try await callback(api.uploadImage(localUrl: result.get()))
                        } catch {
                            handleError(error)
                        }
                    }
                }
            )
            .onChange(of: photoSelection) {
                if let photoSelection {
                    Task {
                        do {
                            try await callback(api.uploadImage(photoSelection))
                            self.photoSelection = nil
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
    }
}

extension View {
    func imageUploadSheets(
        api: ApiClient,
        presentationState: Binding<ImageUploadPresentationState?>,
        callback: @escaping (ImageUpload1) -> Void
    ) -> some View {
        modifier(
            ImageUploadSheetsModifier(
                api: api,
                callback: callback,
                presentationState: presentationState
            )
        )
    }
}
