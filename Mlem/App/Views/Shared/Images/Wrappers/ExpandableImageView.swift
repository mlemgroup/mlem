//
//  ExpandableImageView.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ExpandableImageView: View {
    @Environment(NavigationLayer.self) var navigation
    
    @State var loading: ImageLoadingState = .loading
    let url: URL?
    
    var body: some View {
        DynamicImageView(url: url)
            .onTapGesture {
                if loading == .done, let url {
                    // Sheets don't cover the whole screen on iPad, so use a fullScreenCover instead
                    if UIDevice.isPad {
                        navigation.showFullScreenCover(.imageViewer(url))
                    } else {
                        navigation.openSheet(.imageViewer(url))
                    }
                }
            }
            .onPreferenceChange(ImageLoadingPreferenceKey.self, perform: { loading = $0 })
    }
}
