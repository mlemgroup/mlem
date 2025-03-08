//
//  ReadCheck.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-26.
//

import SwiftUI
import Theming

struct ReadCheck: View {
    let dimension: CGFloat
    
    init(tiled: Bool = false) {
        self.dimension = tiled ? 10 : 12
    }
    
    var body: some View {
        Image(systemName: Icons.success)
            .resizable()
            .scaledToFit()
            .frame(width: dimension, height: dimension)
            .foregroundStyle(.themedSecondary)
    }
}
