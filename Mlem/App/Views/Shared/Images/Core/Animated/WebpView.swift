//
//  WebpView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SDWebImageSwiftUI
import SwiftUI

struct WebpView: View {
    let data: Data
    
    @State var animating: Bool = true
    
    var body: some View {
        AnimatedImage(data: data, isAnimating: $animating)
            .resizable()
            .withAnimationControls(animating: $animating)
    }
}
