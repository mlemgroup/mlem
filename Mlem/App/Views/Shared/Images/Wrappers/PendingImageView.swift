//
//  PendingImageView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-27.
//

import SwiftUI
import UniformTypeIdentifiers
import ImageIO
import Media

struct PendingImageView: View {
    let data: Data
    let contentType: UTType?

    var body: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Text(verbatim: "Error")
        }
    }
}
