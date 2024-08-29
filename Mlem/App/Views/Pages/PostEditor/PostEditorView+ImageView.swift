//
//  PostEditorView+ImageView.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import SwiftUI

extension PostEditorView {
    @ViewBuilder
    var imageView: some View {
        VStack {
            HStack {
                Text("Upload an image...")
                    .fontWeight(.semibold)
                    .padding(.leading, 4)
                Spacer()
                Button("Remove", systemImage: Icons.closeCircleFill) {
                    image = .none
                }
                .font(.title2)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(palette.accent)
                .fontWeight(.semibold)
                .font(.title2)
                .labelStyle(.iconOnly)
            }
            .foregroundStyle(palette.accent)
            HVStack {
                Button("Photos", systemImage: "photo.on.rectangle.angled") {}
                Button("Files", systemImage: "folder") {}
                Button("Paste", systemImage: Icons.paste) {}
            }
            .buttonStyle(ImageSourceButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(palette.accent.opacity(0.2), in: .rect(cornerRadius: 16))
    }
}

private struct ImageSourceButtonStyle: ButtonStyle {
    @Environment(Palette.self) var palette
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(palette.selectedInteractionBarItem)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
            .background(palette.accent, in: .capsule)
    }
}

private struct HVStack<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ViewThatFits {
            HStack { content }
            VStack { content }
        }
    }
}
