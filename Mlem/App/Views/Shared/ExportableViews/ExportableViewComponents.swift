//
//  ExportableViewComponents.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-27.
//

import SwiftUI

struct ExportableViewControlOverlay: View {
    let snapshot: UIImage?
    
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                content
                    .glassEffect(.regular.interactive(), in: .capsule)
            } else {
                content
                    .background(.regularMaterial, in: .capsule)
            }
        }
        .padding(.horizontal, 50)
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
        if let imageData = snapshot?.pngData() {
            Button("Save", icon: .general.import) {
                Task {
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
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if let imageData = snapshot?.pngData(),
           let fileUrl = createTempFile(data: imageData, fileName: "view.png") {
            ShareLink(item: fileUrl)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        } else {
            ProgressView()
        }
    }
    
    private func createTempFile(data: Data, fileName: String) -> URL? {
        do {
            return try data.writeToTempFile(fileName: fileName)
        } catch {
            handleError(error)
            return nil
        }
    }
}
