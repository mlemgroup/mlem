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
            Label(linkLabel, icon: .general.link)
                .lineLimit(1)
                .fontWeight(.semibold)
                .foregroundStyle(.themedAccent)
                .padding(.leading, 8)
                .frame(
                    maxWidth: .infinity,
                    alignment: link == .none ? .center : .leading
                )
            if link != .none {
                Button("Remove", icon: .general.close) {
                    link = .none
                }
                .font(.title2)
                .symbolVariant(.circle.fill)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.themedAccent)
                .fontWeight(.semibold)
            }
        }
        .padding(8)
        .background(.themedAccent.opacity(0.2))
        // This second background is to prevent the view from being partially see-through, which makes the animations cleaner
        .background(.themedGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .onTapGesture { pasteLink() }
    }
    
    private func pasteLink() {
        let url: URL?
        if let pastedUrl = UIPasteboard.general.url {
            url = pastedUrl
        } else if let pastedString = UIPasteboard.general.string, pastedString.starts(with: "http") {
            url = URL(string: pastedString, encodingInvalidCharacters: false)
        } else {
            ToastModel.main.add(.urlCopyError)
            return
        }
        if let url {
            link = .value(.init(content: url, thumbnail: nil, label: ""))
        }
    }
    
    private var linkLabel: String {
        switch link {
        case let .value(link):
            link.content.absoluteString
        default:
            .init(localized: "Add Link")
        }
    }
}
