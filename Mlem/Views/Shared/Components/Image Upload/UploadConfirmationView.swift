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
    let onUpload: () -> Void
    let onCancel: () -> Void
    let imageModel: PictrsImageModel?
    
    var instanceName: String {
        do {
            return try apiClient.session.instanceUrl.host() ?? "your instance"
        } catch {
            return "your instance"
        }
    }
    
    var body: some View {
        switch imageModel?.state {
        case .readyToUpload:
            VStack(spacing: 16) {
                Spacer()
                if let image = imageModel?.image {
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(
                            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                        )
                        .padding(.top)
                }
                Spacer()
                Text("Upload this image to \(instanceName)?")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Spacer()
                Toggle("Ask to confirm every time", isOn: $confirmImageUploads)
                    .controlSize(.mini)
                    .padding(.horizontal)
                Spacer()
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
            .padding(.horizontal)
            
        default:
            Text("Something went wrong.")
        }
    }
}
