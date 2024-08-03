//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    let url: URL
    
    var body: some View {
        ZoomableContainer {
            DynamicImageView(url: url)
                .padding(AppConstants.standardSpacing)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloseButtonView()
            }
        }
    }
}
