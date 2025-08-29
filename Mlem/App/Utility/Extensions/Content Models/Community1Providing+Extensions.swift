//
//  Community1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/05/2024.
//

import Foundation
import Haptics
import MlemMiddleware
import QuickSwipes

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
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            if feedback.contains(.toast) {
                let wasFavorited = self2.favorited
                if self2.subscribed {
                    ToastModel.main.add(
                        .undoable(
                            "Unsubscribed",
                            icon: .lemmy.didUnsubscribe,
                            callback: {
                                if wasFavorited {
                                    self2.updateFavorite(true)
                                } else {
                                    self2.updateSubscribe(true)
                                }
                            },
                            color: .themedAccent
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
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            if feedback.contains(.toast) {
                if self2.favorited {
                    ToastModel.main.add(
                        .undoable(
                            "Unfavorited",
                            icon: .lemmy.unfavorite,
                            callback: {
                                self2.updateFavorite(true)
                            },
                            color: .themedFavorite
                        )
                    )
                } else {
                    ToastModel.main.add(
                        .basic("Favorited", icon: .lemmy.favorite, color: .themedFavorite)
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
                        icon: .lemmy.block,
                        callback: {
                            self.updateBlocked(false)
                        },
                        color: .themedNegative
                    )
                )
            } else {
                ToastModel.main.add(
                    .undoable(
                        "Unblocked",
                        icon: .lemmy.unblock,
                        callback: {
                            self.updateBlocked(true)
                        },
                        color: .themedPrimary
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
        shareAction(navigation: navigation)
        blockAction(appState: appState, feedback: feedback)
        if api.isAdmin {
            ActionGroup {
                if api.supportsOrElse(.removeCommunity, defaultValue: false) {
                    removeAction(appState: appState)
                }
                if api.supportsOrElse(.purgeContent, defaultValue: false) {
                    purgeAction(appState: appState)
                }
            }
        }
    }
    
    func swipeActions(appState: AppState) -> SwipeConfiguration {
        .init(
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
                color: .themedAccent,
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
                color: isOn ? .themedNegative : .themedPositive,
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
                color: .themedFavorite,
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
