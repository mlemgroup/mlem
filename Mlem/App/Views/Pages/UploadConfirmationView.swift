//
//  UploadConfirmationView.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2023.
//

import MlemMiddleware
import PhotosUI
import SwiftUI

struct UploadConfirmationView: View {
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    var imageData: Data
    var imageManager: ImageUploadManager
    var uploadApi: ApiClient
    
    var prompt: String {
        if let host = uploadApi.host {
            .init(localized: "Upload this image to \(host)?")
        } else {
            .init(localized: "Something went wrong")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: Constants.main.largeItemCornerRadius))
                }
                Spacer()
                    .frame(height: 100)
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [palette.background, Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100)
                .allowsHitTesting(false)
            }
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text(prompt)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
//                        Toggle("Ask to confirm every time", isOn: $confirmImageUploads)
//                            .controlSize(.mini)
//                            .padding(.horizontal)
                    Button {
                        Task {
                            do {
                                try await imageManager?.upload(data: imageData, api: uploadApi)
                            } catch {
                                handleError(error)
                            }
                        }
                    } label: {
                        Text("Upload")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                }
                .padding(.top, 15)
                .padding(.bottom, 20)
                .background(palette.background)
            }
            .interactiveDismissDisabled()
        }
        .padding()
    }
}
