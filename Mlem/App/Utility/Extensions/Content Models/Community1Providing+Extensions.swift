//
//  Community1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/05/2024.
//

import Foundation
import MlemMiddleware

extension Community1Providing {
    private var self2: (any Community2Providing)? { self as? any Community2Providing }
    
    var shouldHideInFeed: Bool { blocked }
    
    var canModerate: Bool {
        api.myPerson?.moderates(communityId: id) ?? false || api.isAdmin
    }
    
    // MARK: Operations
    
    @MainActor
    func showNewPostSheet(feedLoader: CommunityPostFeedLoader? = nil) {
        NavigationModel.main.openSheet(.createPost(community: self, feedLoader: feedLoader))
    }
    
    func toggleSubscribe(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            }
            if feedback.contains(.toast) {
                let wasFavorited = self2.favorited
                if self2.subscribed {
                    ToastModel.main.add(
                        .undoable(
                            "Unsubscribed",
                            systemImage: "person.slash.fill",
                            callback: {
                                if wasFavorited {
                                    self2.updateFavorite(true)
                                } else {
                                    self2.updateSubscribe(true)
                                }
                            },
                            color: Palette.main.accent
                        )
                    )
                }
            }
            self2.toggleSubscribe()
        } else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
        }
    }
    
    func toggleFavorite(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            }
            if feedback.contains(.toast) {
                if self2.favorited {
                    ToastModel.main.add(
                        .undoable(
                            "Unfavorited",
                            systemImage: "star.slash.fill",
                            callback: {
                                self2.updateFavorite(true)
                            },
                            color: Palette.main.favorite
                        )
                    )
                } else {
                    ToastModel.main.add(
                        .basic("Favorited", systemImage: "star.fill", color: .blue)
                    )
                }
            }
            self2.toggleFavorite()
        } else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
        }
    }
    
    func toggleBlocked(feedback: Set<FeedbackType>) {
        if feedback.contains(.toast) {
            if !blocked {
                ToastModel.main.add(
                    .undoable(
                        "Blocked",
                        systemImage: Icons.blockFill,
                        callback: {
                            self.updateBlocked(false)
                        },
                        color: Palette.main.negative
                    )
                )
            } else {
                ToastModel.main.add(
                    .undoable(
                        "Unblocked",
                        systemImage: Icons.unblockFill,
                        callback: {
                            self.updateBlocked(true)
                        },
                        color: Palette.main.primary
                    )
                )
            }
        }
        toggleBlocked()
    }
    
    // MARK: Action Collections
    
    @ActionBuilder
    func menuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        navigation: NavigationLayer?,
        feedLoader: CommunityPostFeedLoader?
    ) -> [any Action] {
        newPostAction(appState: appState, feedLoader: feedLoader)
        subscribeAction(appState: appState, feedback: feedback)
        favoriteAction(appState: appState, feedback: feedback)
        openInstanceAction(navigation: navigation)
        copyNameAction()
        shareAction()
        blockAction(appState: appState, feedback: feedback)
        if api.isAdmin {
            ActionGroup {
                removeAction(appState: appState)
                purgeAction(appState: appState)
            }
        }
    }
    
    func swipeActions(appState: AppState, behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            leadingActions: {},
            trailingActions: {
                if api.canInteract(appState: appState) {
                    subscribeAction(appState: appState, feedback: [.haptic])
                    favoriteAction(appState: appState, feedback: [.haptic])
                }
            }
        )
    }
    
    // MARK: Actions
    
    func newPostAction(appState: AppState, feedLoader: CommunityPostFeedLoader?) -> BasicAction {
        let callback: (@MainActor () -> Void)?
        if api.canInteract(appState: appState) {
            callback = {
                self.showNewPostSheet(feedLoader: feedLoader)
            }
        } else {
            callback = nil
        }
        
        return .init(
            id: "newPost\(uid)",
            appearance: .init(
                label: "New Post",
                color: Palette.main.accent,
                icon: Icons.send,
                swipeIcon2: Icons.sendFill
            ),
            callback: callback
        )
    }
    
    func subscribeAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.subscribed ?? false
        return .init(
            id: "subscribe\(actorId.description)",
            appearance: .init(
                label: isOn ? "Unsubscribe" : "Subscribe",
                isOn: isOn,
                isDestructive: isOn,
                color: isOn ? Palette.main.negative : Palette.main.positive,
                icon: isOn ? Icons.unsubscribe : Icons.subscribe,
                swipeIcon1: isOn ? Icons.unsubscribePerson : Icons.subscribePerson,
                swipeIcon2: isOn ? Icons.unsubscribePersonFill : Icons.subscribePersonFill
            ),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.toggleSubscribe(feedback: feedback) } : nil
        )
    }
    
    func favoriteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.favorited ?? false
        return .init(
            id: "favorite\(actorId.description)",
            appearance: .init(
                label: isOn ? "Unfavorite" : "Favorite",
                isOn: isOn,
                color: Palette.main.favorite,
                icon: isOn ? Icons.unfavorite : Icons.favorite,
                menuIcon: isOn ? Icons.favoriteFill : Icons.favorite,
                swipeIcon1: isOn ? Icons.unfavorite : Icons.favorite,
                swipeIcon2: isOn ? Icons.unfavoriteFill : Icons.favoriteFill
            ),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.toggleFavorite(feedback: feedback) } : nil
        )
    }
    
    func blockAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "block\(uid)",
            appearance: .block(isOn: blocked),
            confirmationPrompt: (!blocked && showConfirmation) ? "Really block this community?" : nil,
            callback: api.canInteract(appState: appState) ? { @MainActor in self.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
