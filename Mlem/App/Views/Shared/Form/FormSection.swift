//
//  FormSection.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import SwiftUI

struct FormSection<Content: View>: View {
    @Environment(Palette.self) var palette
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: 10))
    }
}
