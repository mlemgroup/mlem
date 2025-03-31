//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import MlemMiddleware
import SwiftUI
import Theming

private struct QuickSwipeEnvironmentReaderViewModifier: ViewModifier {
    @Environment(\.self) var environment
    
    var buildConfiguration: (EnvironmentValues) -> SwipeConfiguration
    
    init(_ buildConfiguration: @escaping (EnvironmentValues) -> SwipeConfiguration) {
        self.buildConfiguration = buildConfiguration
    }
    
    func body(content: Content) -> some View {
        content.modifier(
            QuickSwipeViewModifier(config: buildConfiguration(environment))
        )
    }
}

extension View {
    /// Adds quick swipes to a view.
    ///
    /// NOTE: if the view you are attaching this to also has a context menu, add the context menu view modifier AFTER the quick swipes modifier! This will prevent the quick swipe from triggering and appearing bugged on an aborted context menu pop if the context menu animation initiates.
    /// - Parameters:
    ///   - leading: leading edge quick swipes, ordered by ascending swipe distance from leading edge
    ///   - trailing: trailing edge quick swipes, ordered by ascending swipe distance from leading edge
    @ViewBuilder
    func quickSwipes(
        leading: [any Action] = [],
        trailing: [any Action] = [],
        dragThresholds: SwipeBehavior = .standard
    ) -> some View {
        modifier(
            QuickSwipeViewModifier(
                config: .init(
                    leadingActions: leading,
                    trailingActions: trailing
                )
            )
        )
    }
    
    @ViewBuilder
    func quickSwipes(_ config: SwipeConfiguration) -> some View {
        modifier(QuickSwipeViewModifier(config: config))
    }
    
    @ViewBuilder
    func quickSwipes(post: any Post, configuration: PostBarConfiguration, behavior: SwipeBehavior) -> some View {
        modifier(
            QuickSwipeEnvironmentReaderViewModifier { environment in
                guard let navigation = environment.navigation, let appState = environment.appState else {
                    assertionFailure()
                    return .init()
                }
                return .init(
                    behavior: behavior,
                    leadingActions: configuration.leadingSwipes.compactMap {
                        post.action(
                            appState: appState,
                            navigation: navigation,
                            type: $0,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    },
                    trailingActions: configuration.trailingSwipes.compactMap {
                        post.action(
                            appState: appState,
                            navigation: navigation,
                            type: $0,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    }
                )
            }
        )
    }
    
    @ViewBuilder
    func quickSwipes(comment: any Comment, configuration: CommentBarConfiguration, behavior: SwipeBehavior) -> some View {
        modifier(
            QuickSwipeEnvironmentReaderViewModifier { environment in
                guard let navigation = environment.navigation, let appState = environment.appState else {
                    assertionFailure()
                    return .init()
                }
                return .init(
                    behavior: behavior,
                    leadingActions: configuration.leadingSwipes.compactMap {
                        comment.action(
                            appState: appState,
                            type: $0,
                            navigation: navigation,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    },
                    trailingActions: configuration.trailingSwipes.compactMap {
                        comment.action(
                            appState: appState,
                            type: $0,
                            navigation: navigation,
                            commentTreeTracker: environment.commentTreeTracker
                        )
                    }
                )
            }
        )
    }
    
    @ViewBuilder
    func quickSwipes(reply: any Reply, configuration: ReplyBarConfiguration, behavior: SwipeBehavior) -> some View {
        modifier(
            QuickSwipeEnvironmentReaderViewModifier { environment in
                guard let navigation = environment.navigation, let appState = environment.appState else {
                    assertionFailure()
                    return .init()
                }
                return .init(
                    behavior: behavior,
                    leadingActions: configuration.leadingSwipes.compactMap {
                        reply.action(appState: appState, type: $0)
                    },
                    trailingActions: configuration.trailingSwipes.compactMap {
                        reply.action(appState: appState, type: $0)
                    }
                )
            }
        )
    }
}
