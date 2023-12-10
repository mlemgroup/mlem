//
//  TappableLinkView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-08.
//

import Foundation
import SwiftUI

/// Enumerates the types of links
/// Equatable so that things like PostModel can be equatable
enum LinkType {
    // TODO: capture internal Lemmy links:
    // - users
    // - communities
    // - posts
    // - comments
    
    case website(String, URL)
    
    var title: String {
        switch self {
        case let .website(title, _):
            return title
        }
    }
}

extension LinkType: Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .website(title, url):
            hasher.combine(0)
            hasher.combine(title)
            hasher.combine(url)
        }
    }
    
    var id: Int { hashValue }
}

struct EasyTapLinkView: View {
    @Environment(\.openURL) private var openURL
    
    let linkType: LinkType
    
    var body: some View {
        switch linkType {
        case let .website(_, url):
            content
                .onTapGesture {
                    openURL(url)
                }
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(linkType.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .bold()
            
            caption
        }
        .padding(AppConstants.postAndCommentSpacing)
        .background(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
            .foregroundColor(Color(UIColor.secondarySystemBackground)))
    }
    
    var caption: some View {
        switch linkType {
        case let .website(_, url):
            websiteCaption(url: url)
        }
    }
    
    private func websiteCaption(url: URL) -> some View {
        Text(url.description)
            .foregroundColor(.secondary)
            .font(.footnote)
    }
}
