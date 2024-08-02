//
//  ExpandableImageView.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ExpandableImageView: View {
    @Environment(NavigationLayer.self) var navigation
    
    @State var loading: DynamicImageView.LoadingState = .waiting
    let url: URL?
    
    var body: some View {
        DynamicImageView(url: url, onLoadingStateChange: { loading = $0 })
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
    }
}
