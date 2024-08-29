//
//  PostEditorView+LinkView.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import SwiftUI

extension PostEditorView {
    @ViewBuilder
    var linkView: some View {
        HStack {
            Label(linkLabel, systemImage: Icons.websiteAddress)
                .lineLimit(1)
                .fontWeight(.semibold)
                .foregroundStyle(palette.accent)
                .padding(.leading, 8)
            Spacer()
            if link == .waiting {
                Button {
                    let url: URL?
                    if let pastedUrl = UIPasteboard.general.url {
                        url = pastedUrl
                    } else if let pastedString = UIPasteboard.general.string, pastedString.starts(with: "http") {
                        url = URL(string: pastedString, encodingInvalidCharacters: false)
                    } else {
                        return
                    }
                    if let url {
                        link = .value(url)
                    }
                } label: {
                    Label("Paste", systemImage: Icons.paste)
                        .foregroundStyle(palette.selectedInteractionBarItem)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(palette.accent, in: .rect(cornerRadius: 8))
                }
            }
            Button("Remove", systemImage: Icons.closeCircleFill) {
                if link == .waiting {
                    link = .none
                } else {
                    link = .waiting
                }
            }
            .font(.title2)
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(palette.accent)
            .fontWeight(.semibold)
        }
        .padding(8)
        .background(palette.accent.opacity(0.2), in: .rect(cornerRadius: 16))
    }
    
    private var linkLabel: String {
        switch link {
        case let .value(url):
            url.absoluteString
        default:
            .init(localized: "Link")
        }
    }
}
