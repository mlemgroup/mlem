//
//  PostEditorView+LinkView.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import MlemMiddleware
import OpenGraph
import SwiftUI

extension PostEditorView {
    @ViewBuilder
    func addLinkButton() -> some View {
        Label("Add Link", icon: .general.link)
            .lineLimit(1)
            .fontWeight(.semibold)
            .foregroundStyle(.themedAccent)
            .padding(.leading, 8)
            .frame(
                maxWidth: .infinity,
                alignment: link == .none ? .center : .leading
            )
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
            Task {
                do {
                    link = try await .value(generatePostLink(url: url))
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    private func generatePostLink(url: URL) async throws -> PostLink {
        if let api = targets.first?.account.api, try await api.supports(.fetchLinkMetadata) {
            return try await api.getPostLink(url: url)
        }
        let metadata = try await OpenGraph.fetch(url: url)
        let thumbnailUrl = metadata[.image].map { URL(string: $0) } ?? nil
        return .init(content: url, thumbnail: thumbnailUrl, label: metadata[.title] ?? url.absoluteString)
    }
}
