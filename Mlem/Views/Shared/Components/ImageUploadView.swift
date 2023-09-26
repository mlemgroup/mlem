//
//  ImageUploadView.swift
//  Mlem
//
//  Created by Sjmarf on 26/09/2023.
//

import SwiftUI

struct PictrsImageModel {
    enum UploadState {
        case uploading(progress: Double)
        case uploaded(file: PictrsFile?)
        case failed(Error)
    }
    var image: Image?
    var file: PictrsFile?
    var state: UploadState = .uploading(progress: 0)
}

struct ImageUploadView: View {
    var imageModel: PictrsImageModel
    let onCancel: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: AppConstants.postAndCommentSpacing) {
                if let image = imageModel.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
                } else {
                    placeHolderImage
                }
                VStack(alignment: .leading) {
                    Text("Attached Image")
                    Spacer()
                    HStack {
                        switch imageModel.state {
                        case .uploading(let progress):
                            Text("Uploading...")
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 100, height: 10)
                        case .uploaded:
                            Text("Uploaded")
                        case .failed:
                            Text("Failed")
                                .foregroundStyle(.red)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                .frame(height: AppConstants.thumbnailSize - 20)
                Spacer()
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .fill(Color(UIColor.secondarySystemBackground))
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onCancel, label: {
                Image(systemName: "multiply")
                    .fontWeight(.semibold)
                    .tint(.secondary)
                    .padding(5)
                    .background(Circle().fill(.background))
            })
            .padding(5)
        }
    }
    
    @ViewBuilder
    var placeHolderImage: some View {
        RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
            .fill(.secondary)
            .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
    }
}
