//
//  TappableLinkView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-08.
//

import Foundation
import SwiftUI

struct EasyTapLinkView: View {
    @Environment(\.openURL) private var openURL
    
    let title: String
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .bold()
            HStack(alignment: .center, spacing: 0.0) {
                Text(url.description)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
        .padding(AppConstants.postAndCommentSpacing)
        .background(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
            .foregroundColor(Color(UIColor.secondarySystemBackground)))
        .onTapGesture {
            openURL(url)
        }
    }
}
