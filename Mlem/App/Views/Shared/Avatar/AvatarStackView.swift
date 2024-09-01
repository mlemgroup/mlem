//
//  AvatarStackView.swift
//  Mlem
//
//  Created by Sjmarf on 08/05/2024.
//

import SwiftUI

struct AvatarStackView: View {
    let urls: [URL?]
    let fallback: FixedImageView.Fallback
    
    let height: CGFloat
    let spacing: CGFloat
    let outlineWidth: CGFloat
    
    var showPlusIcon: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer().aspectRatio(1 / 2, contentMode: .fit)
            HStack(spacing: spacing) {
                ForEach(showPlusIcon ? urls : urls.dropLast(), id: \.self) { url in
                    avatarView(url: url)
                        .frame(maxWidth: 0)
                        .padding(outlineWidth)
                        .mask {
                            Rectangle()
                                .subtracting(.circle.offset(x: spacing))
                                .aspectRatio(contentMode: .fill)
                        }
                }
                if showPlusIcon {
                    plusIconView
                        .frame(maxWidth: 0)
                        .padding(outlineWidth)
                } else {
                    avatarView(url: urls.last ?? nil)
                        .frame(maxWidth: 0)
                        .padding(outlineWidth)
                }
            }
            Spacer().aspectRatio(1 / 2, contentMode: .fit)
        }
    }
    
    @ViewBuilder
    var plusIconView: some View {
        Image(systemName: "plus.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.secondary, Color(uiColor: .tertiaryLabel))
    }
    
    @ViewBuilder
    func avatarView(url: URL?) -> some View {
        CircleCroppedImageView(
            url: url,
            frame: height,
            fallback: fallback
        )
        .aspectRatio(contentMode: .fill)
    }
}

#Preview {
    AvatarStackView(
        urls: .init(repeating: nil, count: 3),
        fallback: .person,
        height: 64,
        spacing: 48,
        outlineWidth: 1
    )
    .frame(height: 64)
}
