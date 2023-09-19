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
    var cornerRadius: CGFloat = 0
    
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
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                Text("NSFW")
                    .fontWeight(.black)
                Text("Tap to view")
                    .font(.callout)
            }
            .minimumScaleFactor(0.01)
            .foregroundColor(.white)
//            .padding(8)
            .highPriorityGesture(
                TapGesture()
                    .onEnded {
                        showNsfwFilterToggle.toggle()
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
            .cornerRadius(cornerRadius)
        } else if isNsfw, shouldBlurNsfw {
            Image(systemName: "eye.slash")
                .foregroundColor(.white)
                .padding(4)
                .background(.thinMaterial)
                .cornerRadius(AppConstants.smallItemCornerRadius)
                .highPriorityGesture(
                    TapGesture()
                        .onEnded {
                            showNsfwFilterToggle.toggle()
                        }
                )
                .padding(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

extension View {
    func applyNsfwOverlay(_ isNsfw: Bool, cornerRadius: CGFloat = 0) -> some View {
        modifier(NSFWOverlay(isNsfw: isNsfw, cornerRadius: cornerRadius))
    }
}
