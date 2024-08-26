//
//  FormChevron.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct FormChevron<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: Icons.forward)
                .imageScale(.small)
                .foregroundStyle(Palette.main.tertiary)
                .fontWeight(.semibold)
        }
        .contentShape(.rect)
    }
}
