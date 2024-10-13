//
//  CrossPostListView.swift
//  Mlem
//
//  Created by Sjmarf on 25/09/2024.
//

import MlemMiddleware
import SwiftUI

struct CrossPostListView: View {
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    @Environment(Palette.self) private var palette
    
    let post: any Post3Providing
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        if !post.crossPosts.isEmpty {
            VStack(spacing: Constants.main.halfSpacing) {
                Button {
                    HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                    withAnimation(.easeOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: Icons.crossPost)
                            .foregroundStyle(palette.secondary)
                            .fontWeight(.semibold)
                        Text("\(post.crossPosts.count) Crossposts...")
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: Icons.replies)
                            Text(String(post.crossPosts.reduce(0) { $0 + $1.commentCount }))
                        }
                        .font(.footnote)
                        .foregroundStyle(palette.secondary)
                    }
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .contentShape(.rect)
                }
                .buttonStyle(.empty)
                if isExpanded {
                    Divider()
                        .padding(.vertical, 3)
                    Grid(alignment: .leading) {
                        ForEach(post.crossPosts) { crossPost in
                            GridRow {
                                FullyQualifiedLabelView(
                                    entity: crossPost.community,
                                    labelStyle: .medium,
                                    blurred: crossPost.nsfw
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                ReadoutView(readout: crossPost.createdReadout, showColor: true)
                                ReadoutView(readout: crossPost.scoreReadout, showColor: true)
                                ReadoutView(readout: crossPost.commentReadout, showColor: true)
                            }
                            .contentShape(.rect)
                            .onTapGesture {
                                navigation.push(.post(crossPost))
                            }
                        }
                    }
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .font(.footnote)
                    .foregroundStyle(palette.secondary)
                }
            }
            .padding(.vertical, 8)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
    }
}
