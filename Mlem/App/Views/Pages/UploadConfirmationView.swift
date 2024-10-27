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
    
    @Setting(\.confirmImageUploads) var confirmImageUploads
    
    var imageData: Data
    var imageManager: ImageUploadManager
    var uploadApi: ApiClient
    
    @State var isUploading: Bool = false
    
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
                    if isUploading {
                        VStack {
                            Text("Uploading...")
                            ProgressView()
                        }
                        .font(.title3)
                        .padding(.vertical, 100)
                    } else {
                        Text(prompt)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                        Toggle("Ask to confirm every time", isOn: $confirmImageUploads)
                            .controlSize(.mini)
                            .padding(.horizontal)
                        Button {
                            Task { @MainActor in
                                isUploading = true
                                do {
                                    try await imageManager.upload(data: imageData, api: uploadApi)
                                    HapticManager.main.play(haptic: .success, priority: .low)
                                    dismiss()
                                } catch {
                                    handleError(error)
                                }
                                isUploading = false
                            }
                        } label: {
                            Text("Upload")
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .fixedSize(horizontal: false, vertical: true)
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
                }
                .padding(.top, 15)
                .padding(.bottom, 20)
                .background(palette.background)
            }
            .interactiveDismissDisabled()
            .animation(.easeOut(duration: 0.1), value: isUploading)
        }
        .padding()
    }
}
