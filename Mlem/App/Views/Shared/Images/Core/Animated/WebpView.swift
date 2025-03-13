//
//  WebpView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SDWebImageSwiftUI
import SwiftUI

struct WebpView: View {
    @Environment(MediaControlState.self) var controlState
    
    let data: Data
    
    var body: some View {
        AnimatedImage(
            data: data,
            isAnimating: Binding(
                get: { controlState.animating },
                set: { controlState.animating = $0 }
            )
        )
        // https://github.com/SDWebImage/SDWebImageSwiftUI/issues/114#issuecomment-636737317
        .onViewCreate { view, _ in
            view.autoPlayAnimatedImage = controlState.animating
        }
        .resizable()
    }
}
