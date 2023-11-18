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
        ZoomableImageView(url: url)
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
}
