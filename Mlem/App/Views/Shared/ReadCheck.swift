//
//  ReadCheck.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-26.
//

import SwiftUI
import Theming

struct ReadCheck: View {
    @Environment(\.self) var environment
    
    let dimension: CGFloat
    
    init(tiled: Bool = false) {
        self.dimension = tiled ? 10 : 12
    }
    
    var body: some View {
        Image(systemName: Icons.success)
            .resizable()
            .scaledToFit()
            .frame(width: dimension, height: dimension)
            .foregroundColor(ThemedShapeStyle.themedSecondary.resolve(in: environment))
    }
}
