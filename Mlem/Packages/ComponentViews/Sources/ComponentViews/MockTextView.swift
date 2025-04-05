//
//  MockTextView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-27.
//

import SwiftUI
import Theming

public struct MockTextView: View {
    @Environment(\.palette) var palette
    
    let beginOpacity: CGFloat
    let endOpacity: CGFloat
    
    public init(beginOpacity: CGFloat? = nil, endOpacity: CGFloat? = nil) {
        self.beginOpacity = beginOpacity ?? 0.55
        self.endOpacity = endOpacity ?? 0.45
    }
    
    public var body: some View {
        Capsule()
            .fill(LinearGradient(
                colors: [
                    palette.label.secondary.opacity(beginOpacity),
                    palette.label.secondary.opacity(endOpacity)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ))
    }
}
