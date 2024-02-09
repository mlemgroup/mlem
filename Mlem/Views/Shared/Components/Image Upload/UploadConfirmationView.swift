//
//  UploadConfirmationView.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2023.
//

import SwiftUI
import PhotosUI
import Dependencies

struct UploadConfirmationView: View {
    @Dependency(\.apiClient) var apiClient
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = false
    
    @Binding var isPresented: Bool
    @Binding var imageModel: PictrsImageModel?
    
    let onUpload: () -> Void
    let onCancel: () -> Void
    
    var instanceName: String {
        do {
            return try apiClient.session.instanceUrl.host() ?? "your instance"
        } catch {
            return "your instance"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let image = imageModel?.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(
                            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                        )
                }
                Spacer()
                    .frame(height: 100)
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.systemBackground, Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100)
                .allowsHitTesting(false)
            }
            switch imageModel?.state {
            case .readyToUpload:
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        Text("Upload this image to \(instanceName)?")
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                        Toggle("Ask to confirm every time", isOn: $confirmImageUploads)
                            .controlSize(.mini)
                            .padding(.horizontal)
                        Button {
                            onUpload()
                            isPresented = false
                        } label: {
                            Text("Upload")
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        Button {
                            onCancel()
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 20)
                    .background(Color.systemBackground)
                }
                .interactiveDismissDisabled()
            
            default:
                Text("Something went wrong.")
            }
        }
        .padding()
    }
}
