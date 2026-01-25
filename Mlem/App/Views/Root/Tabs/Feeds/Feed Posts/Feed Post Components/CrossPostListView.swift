//
//  CrossPostListView.swift
//  Mlem
//
//  Created by Sjmarf on 25/09/2024.
//

import Haptics
import MlemMiddleware
import SwiftUI

struct CrossPostListView: View {
    @Environment(AppState.self) private var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) private var navigation
    
    let post: Post
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        // does not use ExpectedView because of padding reasons and because the animation is not necessary
        if let crossPosts = post.crossPosts.value {
            content(crossPosts)
        }
    }
    
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(_ crossPosts: [Post]) -> some View {
        if !crossPosts.isEmpty {
            VStack(spacing: Constants.main.halfSpacing) {
                Button {
                    hapticManager.play(haptic: .gentleInfo, tier: .low)
                    withAnimation(.easeOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Image(icon: .lemmy.crosspost)
                            .foregroundStyle(.themedSecondary)
                            .fontWeight(.semibold)
                        Text("\(crossPosts.count) Crossposts...")
                        Spacer()
                        HStack(spacing: 2) {
                            Image(icon: .lemmy.comment)
                            Text(String(crossPosts.reduce(0) { $0 + ($1.commentCount.value ?? 0) }))
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
                        ForEach(crossPosts) { crossPost in
                            GridRow {
                                ExpectedView(crossPost.community) { community in
                                    FullyQualifiedLabelView(community, labelStyle: .medium, blurred: crossPost.nsfw)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } placeholder: {
                                    Text(verbatim: .communityPlaceholder).redacted(reason: .placeholder)
                                }
                                ReadoutView(readout: crossPost.createdReadout)
                                if let scoreReadout = crossPost.scoreReadout(showColor: true) {
                                    ReadoutView(readout: scoreReadout)
                                }
                                if let commentReadout = crossPost.commentReadout {
                                    ReadoutView(readout: commentReadout)
                                }
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
            .contentShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
            .contextMenu {
                Button("Mark Read", icon: .lemmy.markRead) {
                    Task { await markAllAsRead(crossPosts) }
                }
            }
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
    }

    func markAllAsRead(_ crossPosts: [Post]) async {
        do {
            try await post.api.markPostsAsRead(ids: Set(crossPosts.map(\.id)))
            ToastModel.main.add(.success("Read \(crossPosts.count) posts"))
        } catch {
            handleError(error)
        }
    }
}
