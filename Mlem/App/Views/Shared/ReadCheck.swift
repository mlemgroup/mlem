//
//  ReadCheck.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-26.
//

import SwiftUI

struct ReadCheck: View {
    
    @Environment(Palette.self) var palette
    
    let dimension: CGFloat
    
    init(tiled: Bool = false) {
        dimension = tiled ? 10 : 12
    }
    
    var body: some View {
        Image(systemName: Icons.success)
            .resizable()
            .scaledToFit()
            .frame(width: dimension, height: dimension)
            .foregroundColor(palette.secondary)
    }
}
