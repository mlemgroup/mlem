//
//  ExportableViewComponents.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-27.
//

import SwiftUI

struct ExportableViewControlOverlay: View {
    // let snapshot: UIImage?
    let createSnapshot: () -> UIImage?
    
    var body: some View {
        content
            .glassEffect(.regular.interactive(), in: .capsule)
            .padding(Constants.main.standardSpacing)
    }
    
    var content: some View {
        HStack {
            saveButton
            shareButton
        }
        .font(.title2)
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .padding(.horizontal, Constants.main.halfSpacing)
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button("Save", icon: .general.import) {
            Task {
                guard let imageData = createSnapshot()?.pngData() else {
                    assertionFailure("Rendering failed")
                    ToastModel.main.add(.failure("Failed"))
                    return
                }
                do {
                    try await ImageSaver().writeImageToPhotoAlbum(imageData: imageData)
                    ToastModel.main.add(.success("Image Saved"))
                } catch {
                    handleError(error)
                }
            }
        }
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
    }
    
    @ViewBuilder
    var shareButton: some View {
        ShareLink(
            item: TransferableUIImage(createImage: createSnapshot),
            preview: SharePreview(
                "Image",
                image: TransferableUIImage(createImage: createSnapshot)
            ))
        .padding(Constants.main.standardSpacing)
        .contentShape(.rect)
    }
}

private struct TransferableUIImage: Transferable {
    var createImage: () -> UIImage?
    
    enum TranferableUIImageError: Error {
        case generationFailed
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            guard let imageData = item.createImage()?.pngData() else {
                throw TranferableUIImageError.generationFailed
            }
            return imageData
        }
    }
}
