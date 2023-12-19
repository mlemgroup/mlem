//
//  UploadProgressView.swift
//  Mlem
//
//  Created by Sjmarf on 17/12/2023.
//

import SwiftUI

struct UploadProgressView: View {
    let imageModel: PictrsImageModel?
    
    var body: some View {
        HStack {
            switch imageModel?.state {
            case .uploading(let progress):
                if progress == 1 {
                    Text("Processing...")
                    ProgressView()
                        .controlSize(.small)
                        .padding(.horizontal, 6)
                } else {
                    Text("Uploading")
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 80, height: 10)
                }
            case .uploaded:
                Text("Uploaded")
            case .failed(let msg):
                Text(msg ?? "Failed")
                    .foregroundStyle(.red)
            default:
                Text("Waiting...")
            }
        }
        .foregroundStyle(.secondary)
    }
}
