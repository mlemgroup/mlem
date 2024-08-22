//
//  View+ComputeBlur.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-22.
//

import Foundation
import SwiftUI

private struct DynamicBlur: ViewModifier {
    @State var blurValue: CGFloat = 100
    let blurred: Bool
    
    func body(content: Content) -> some View {
        content
            .blur(radius: blurred ? blurValue : 0, opaque: true)
            .background {
                GeometryReader { geo in
                    Color.clear.contentShape(.rect)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onChange(of: geo.size, initial: true) {
                            blurValue = max(geo.size.width, geo.size.height) / 12
                        }
                }
            }
    }
}

extension View {
    /// Blurs an image relative to its size
    func dynamicBlur(blurred: Bool) -> some View {
        modifier(DynamicBlur(blurred: blurred))
    }
}
