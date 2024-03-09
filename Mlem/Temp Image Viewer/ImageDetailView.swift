//
//  ImageDetailView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-15.
//

import Foundation
import SwiftUI

struct ImageDetailView: View {    
    let url: URL
    
    var body: some View {
        ZoomableImageView(url: url)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButtonView()
                }
            }
    }
}
