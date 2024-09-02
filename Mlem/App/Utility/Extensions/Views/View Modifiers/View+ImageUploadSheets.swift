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
    let imageManager: ImageUploadManager?
    let api: ApiClient
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
                            try await imageManager?.uploadFile(localUrl: result.get(), api: api)
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
                            try await imageManager?.uploadPhoto(photoSelection, api: api)
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
        imageManager: ImageUploadManager?,
        api: ApiClient,
        presentationState: Binding<ImageUploadPresentationState?>
    ) -> some View {
        modifier(
            ImageUploadSheetsModifier(
                imageManager: imageManager,
                api: api,
                presentationState: presentationState
            )
        )
    }
}
