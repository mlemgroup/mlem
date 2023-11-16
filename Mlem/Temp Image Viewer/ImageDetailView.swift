//
//  ImageDetailView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-15.
//

import Foundation
import SwiftUI

struct ImageDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let url: URL
    
    var body: some View {
        image
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: Icons.close)
                    }
                }
            }
    }
    
    @ViewBuilder
    var image: some View {
        if #available(iOS 16.4, *) {
            ZoomableImageView(url: url)
                .presentationBackground(.regularMaterial)
        } else {
            ZoomableImageView(url: url)
        }
    }
}
