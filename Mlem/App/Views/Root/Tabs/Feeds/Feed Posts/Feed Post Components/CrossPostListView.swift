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
                        Image(icon: .lemmy.crosspost)
                            .foregroundStyle(.themedSecondary)
                            .fontWeight(.semibold)
                        Text("\(post.crossPosts.count) Crossposts...")
                        Spacer()
                        HStack(spacing: 2) {
                            Image(icon: .lemmy.comment)
                            Text(String(post.crossPosts.reduce(0) { $0 + $1.commentCount }))
                        }
                        .font(.footnote)
                        .foregroundStyle(.themedSecondary)
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
                                FullyQualifiedLabelView(crossPost.community, labelStyle: .medium, blurred: crossPost.nsfw)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ReadoutView(readout: crossPost.createdReadout)
                                ReadoutView(readout: crossPost.scoreReadout(showColor: true))
                                ReadoutView(readout: crossPost.commentReadout)
                            }
                            .contentShape(.rect)
                            .onTapGesture {
                                navigation.push(.post(crossPost))
                            }
                        }
                    }
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
                }
            }
            .padding(.vertical, 8)
            .background(.themedSecondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
    }
}
