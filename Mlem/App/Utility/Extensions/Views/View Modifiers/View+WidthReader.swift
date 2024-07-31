//
//  View+WidthReader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-28.
//

import Foundation
import SwiftUI

private struct WidthReader: ViewModifier {
    @Binding var width: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.size.width, initial: true) {
                            width = geo.size.width
                        }
                }
            }
    }
}

extension View {
    /// Convenience modifier. Attach to a view to load items from the given FeedLoading on appear if the given FeedLoading has no items
    func widthReader(width: Binding<CGFloat>) -> some View {
        modifier(WidthReader(width: width))
    }
}
