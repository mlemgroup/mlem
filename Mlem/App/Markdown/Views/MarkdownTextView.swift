//
//  MarkdownText.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import SwiftUI

struct MarkdownTextView: View {
    private var renderer: MarkdownTextRenderer
    
    init(_ inlines: [MarkdownInlineNode]) {
        self.renderer = .init(inlines: inlines)
    }
    
    init(_ string: String) {
        self.init(UnsafeMarkdownNode.parseInlinesOnly(markdown: string) ?? [])
    }
    
    private func text(components: [MarkdownTextRenderer.Component]) -> some View {
        var text = Text("")
        for component in components {
            switch component {
            case let .text(attributedString):
                // swiftlint:disable:next shorthand_operator
                text = text + Text(attributedString)
            case let .image(attatchment):

                let image: Image = attatchment.image ?? Image(systemName: "arrow.down.circle")
                // swiftlint:disable:next shorthand_operator
                text = text + Text(image)
            }
        }
        return text
    }
    
    var body: some View {
        switch renderer.type {
        case let .text(components, attatchments):
            text(components: components)
                .task {
                    for attatchment in attatchments {
                        try? await attatchment.load(resize: true)
                    }
                }
        case .singleImage:
            Image(systemName: "photo")
                .imageScale(.large)
                .padding(50)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        default:
            Text("Error")
        }
    }
}
