//
//  View+CustomBadge.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-25.
//

import Foundation
import SwiftUI

struct CustomBadge: ViewModifier {
    let count: Int?
    
    let padding: CGFloat = 3.5
    
    @State var computedOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        // the goal of this configuration is to place the center of the badge on the trailing edge of the content without modifying the content's positioning--i.e., if the badge spills over, we do not want to shift the content to the left
        ZStack(alignment: .topTrailing) {
            content
            customBadge
                .offset(x: computedOffset - padding) // adjust for padding because geometryReader doesn't respect it
                .overlay {
                    // geometryReader in an overlay to prevent it from doing bad things to the layout
                    GeometryReader { geo in
                        // dummy item with an onAppear to compute and update the offset
                        Color(uiColor: .clear)
                            .onAppear { computedOffset = 0.5 * geo.size.width }
                    }
                }
        }
    }
    
    @ViewBuilder
    var customBadge: some View {
        if let count, count != 0 {
            Text(count.description)
                .font(.system(size: 10))
                .padding(.vertical, 1)
                .padding(.horizontal, padding)
                .foregroundColor(.white)
                .background {
                    Capsule()
                        .foregroundColor(.red)
                }
        }
    }
}

extension View {
    func customBadge(_ count: Int?) -> some View {
        modifier(CustomBadge(count: count))
    }
}
