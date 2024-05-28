//
//  TilePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-27.
//

import Foundation
import MlemMiddleware
import Nuke
import NukeUI
import SwiftUI

struct TilePost: View {
    @Environment(\.self) var environment
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing

    // magic number alert! ((footnote size + leading) / 2) + (vertical padding on capsules) = (18 / 2) + (2) = 11
    @ScaledMetric(relativeTo: .footnote) var cornerRadius: CGFloat = 11
    var dimension: CGFloat { UIScreen.main.bounds.width / 2 - (AppConstants.standardSpacing * 1.5) }
    var outerCornerRadius: CGFloat { cornerRadius + AppConstants.compactSpacing }
    
    var body: some View {
        content
            .frame(width: dimension, height: dimension)
            .clipShape(.rect(cornerRadius: outerCornerRadius))
            .background {
                RoundedRectangle(cornerRadius: outerCornerRadius)
                    .fill(palette.background)
            }
    }
    
    @State var color: Color = .clear
    
    var content: some View {
        HStack(alignment: .top, spacing: 0) {
            TilePostImage(post: post, color: $color)
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .foregroundStyle(foregroundColor)
                        HStack(spacing: 2) {
                            Text(post.community_?.name ?? "")
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "arrow.up")
                            Text("\(Int.random(in: 100 ... 1000))")
                        }
                        .fontWeight(.semibold)
                        .font(.caption)
                        .foregroundStyle(foregroundColor.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 6)
                    .padding(.horizontal, 10)
                }
        }
    }
    
    var foregroundColor: Color {
        isBlack ? .black : .white
    }
    
    var isBlack: Bool {
        let resolved = color.resolve(in: environment)
        return (resolved.red * 0.299 + resolved.green * 0.587 + resolved.blue * 0.114) > (186 / 255)
    }
    
    // TODO: this should be fleshed out to use live values--requires some middleware work to make those conveniently available. This is just a quick-and-dirty way to mock up how it would look.
    var info: Text {
        Text(Image(systemName: Icons.upvoteSquare)) +
            Text("34") +
            Text("  ") +
            Text(Image(systemName: Icons.save)) +
            Text("  ") +
            Text(Image(systemName: Icons.replies)) +
            Text("12")
    }
}
