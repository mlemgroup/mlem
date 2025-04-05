//
//  FormChevron.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

public struct FormChevron<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.forward")
                .imageScale(.small)
                .foregroundStyle(.themedTertiary)
                .fontWeight(.semibold)
        }
        .contentShape(.rect)
    }
}
