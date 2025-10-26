//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-23.
//

import MlemMiddleware
import QuickSwipes
import SwiftUI

private struct QuickSwipeEnvironmentReaderViewModifier: ViewModifier {
    @Environment(\.self) var environment
    
    var buildConfiguration: (EnvironmentValues) -> SwipeConfiguration
    
    init(_ buildConfiguration: @escaping (EnvironmentValues) -> SwipeConfiguration) {
        self.buildConfiguration = buildConfiguration
    }
    
    func body(content: Content) -> some View {
        content.quickSwipes(buildConfiguration(environment))
    }
}

extension View {
    @ViewBuilder
    func quickSwipes(
        leading: [any Action] = [],
        trailing: [any Action] = []
    ) -> some View {
        quickSwipes(.init(leadingActions: leading, trailingActions: trailing))
    }
    
    @ViewBuilder
    func quickSwipes(post: any Post, configuration: PostBarConfiguration) -> some View {
        modifier(
            QuickSwipeEnvironmentReaderViewModifier { environment in
                guard let navigation = environment.navigation else {
                    assertionFailure()
                    return .init()
                }
                return .init(
                    leadingActions: configuration.leadingSwipes.compactMap {
                        post.action(
                            appState: environment.appState,
                            navigation: navigation,
                            type: $0,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    }.compactMap(QuickSwipeAction.init),
                    trailingActions: configuration.trailingSwipes.compactMap {
                        post.action(
                            appState: environment.appState,
                            navigation: navigation,
                            type: $0,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    }.compactMap(QuickSwipeAction.init)
                )
            }
        )
    }
    
    @ViewBuilder
    func quickSwipes(comment: any Comment, configuration: CommentBarConfiguration) -> some View {
        modifier(
            QuickSwipeEnvironmentReaderViewModifier { environment in
                guard let navigation = environment.navigation else {
                    assertionFailure()
                    return .init()
                }
                return .init(
                    leadingActions: configuration.leadingSwipes.compactMap {
                        comment.action(
                            appState: environment.appState,
                            type: $0,
                            navigation: navigation,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    }.compactMap(QuickSwipeAction.init),
                    trailingActions: configuration.trailingSwipes.compactMap {
                        comment.action(
                            appState: environment.appState,
                            type: $0,
                            navigation: navigation,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    }.compactMap(QuickSwipeAction.init)
                )
            }
        )
    }
    
    @ViewBuilder
    func quickSwipes(reply: any Reply, configuration: ReplyBarConfiguration) -> some View {
        modifier(
            QuickSwipeEnvironmentReaderViewModifier { environment in
                guard environment.navigation != nil else {
                    assertionFailure()
                    return .init()
                }
                return .init(
                    leadingActions: configuration.leadingSwipes.compactMap {
                        reply.action(appState: environment.appState, type: $0)
                    }.compactMap(QuickSwipeAction.init),
                    trailingActions: configuration.trailingSwipes.compactMap {
                        reply.action(appState: environment.appState, type: $0)
                    }.compactMap(QuickSwipeAction.init)
                )
            }
        )
    }
}
