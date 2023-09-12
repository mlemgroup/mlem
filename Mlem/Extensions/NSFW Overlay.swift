//
//  NSFW Overlay.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct NSFWOverlay: ViewModifier {
    let isNsfw: Bool
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @State var showNsfwFilterToggle: Bool = true
    var showNsfwFilter: Bool { isNsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }
    
    func body(content: Content) -> some View {
        content
            .overlay(nsfwOverlay)
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
            .foregroundColor(.white)
            .padding(8)
            .onTapGesture {
                showNsfwFilterToggle.toggle()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
            .cornerRadius(AppConstants.largeItemCornerRadius)
        } else if isNsfw, shouldBlurNsfw {
            Image(systemName: "eye.slash")
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
    func applyNsfwOverlay(_ isNsfw: Bool) -> some View {
        modifier(NSFWOverlay(isNsfw: isNsfw))
    }
}
