//
//  NSFW Overlay.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct NSFWOverlay: ViewModifier {
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    let isNsfw: Bool
    let tapAnywhereToReveal: Bool
    
    @State var showNsfwFilterToggle: Bool = true
    
    var showNsfwFilter: Bool { isNsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if tapAnywhereToReveal {
                    nsfwOverlay
                        .onTapGesture { showNsfwFilterToggle.toggle() }
                } else {
                    nsfwOverlay
                }
            }
    }
    
    @ViewBuilder
    var nsfwOverlay: some View {
        if showNsfwFilter {
            VStack {
                Image(systemName: Icons.warning)
                    .font(.largeTitle)
                Text("NSFW")
                    .fontWeight(.black)
                Text("Tap to view")
                    .font(.callout)
            }
            .foregroundColor(.white)
            .padding(8)
            .onTapGesture {
                showNsfwFilterToggle.toggle()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
            .cornerRadius(AppConstants.largeItemCornerRadius)
        } else if isNsfw, shouldBlurNsfw {
            Image(systemName: Icons.nsfw)
                .foregroundColor(.white)
                .padding(4)
                .background(.thinMaterial)
                .cornerRadius(AppConstants.smallItemCornerRadius)
                .onTapGesture {
                    showNsfwFilterToggle.toggle()
                }
                .padding(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

extension View {
    func applyNsfwOverlay(_ isNsfw: Bool, canTapFullImage: Bool = false) -> some View {
        modifier(NSFWOverlay(isNsfw: isNsfw, tapAnywhereToReveal: canTapFullImage))
    }
}
