//
//  AvatarStackView.swift
//  Mlem
//
//  Created by Sjmarf on 08/05/2024.
//

import SwiftUI

struct AvatarStackView: View {
    let urls: [URL?]
    let type: AvatarType
    
    let spacing: CGFloat
    let outlineWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer().aspectRatio(1 / 2, contentMode: .fit)
            HStack(spacing: spacing) {
                ForEach(urls.dropLast(), id: \.self) { url in
                    avatarView(url: url)
                        .frame(maxWidth: 0)
                        .padding(outlineWidth)
                        .mask {
                            ZStack(alignment: .trailing) {
                                Rectangle()
                                Circle()
                                    .padding(.trailing, -spacing)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                            .aspectRatio(contentMode: .fill)
                        }
                }
                avatarView(url: urls.last ?? nil)
                    .frame(maxWidth: 0)
                    .padding(outlineWidth)
            }
            Spacer().aspectRatio(1 / 2, contentMode: .fit)
        }
    }
    
    @ViewBuilder
    func avatarView(url: URL?) -> some View {
        AvatarView(
            url: url,
            type: type
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    AvatarStackView(
        urls: .init(repeating: nil, count: 3),
        type: .person,
        spacing: 48,
        outlineWidth: 1
    )
    .frame(height: 64)
}
