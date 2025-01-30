//
//  MockTextView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-27.
//

import SwiftUI

struct MockTextView: View {
    @Environment(Palette.self) var palette
    
    let beginOpacity: CGFloat
    let endOpacity: CGFloat
    
    init(beginOpacity: CGFloat? = nil, endOpacity: CGFloat? = nil) {
        self.beginOpacity = beginOpacity ?? 0.55
        self.endOpacity = endOpacity ?? 0.45
    }
    
    var body: some View {
        Capsule()
            .fill(LinearGradient(
                colors: [palette.secondary.opacity(beginOpacity), palette.secondary.opacity(endOpacity)],
                startPoint: .leading,
                endPoint: .trailing
            ))
    }
}
