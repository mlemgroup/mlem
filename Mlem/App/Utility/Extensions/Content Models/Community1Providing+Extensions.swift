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
    
    // MARK: Operations
    
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
            print("DEBUG no self2 found in toggleSubscribe!")
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
            print("DEBUG no self2 found in toggleFavorite!")
        }
    }
    
    func toggleBlocked(feedback: Set<FeedbackType>) {
        if !blocked, feedback.contains(.toast) {
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
        }
        toggleBlocked()
    }
    
    // MARK: Action Collections
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic],
        navigation: NavigationLayer?
    ) -> [any Action] {
        newPostAction()
        subscribeAction(feedback: feedback)
        favoriteAction(feedback: feedback)
        openInstanceAction(navigation: navigation)
        copyNameAction()
        shareAction()
        blockAction()
    }
    
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            leadingActions: {},
            trailingActions: {
                if api.isAuthenticatedAndActive {
                    subscribeAction(feedback: [.haptic])
                    favoriteAction(feedback: [.haptic])
                }
            }
        )
    }
    
    // MARK: Actions
    
    func newPostAction() -> BasicAction {
        .init(
            id: "newPost\(uid)",
            isOn: false,
            label: "New Post",
            color: Palette.main.accent,
            icon: Icons.send,
            swipeIcon2: Icons.sendFill,
            callback: nil // TODO:
        )
    }
    
    func subscribeAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.subscribed ?? false
        return .init(
            id: "subscribe\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Unsubscribe" : "Subscribe",
            color: isOn ? Palette.main.negative : Palette.main.positive,
            isDestructive: isOn,
            icon: isOn ? Icons.unsubscribe : Icons.subscribe,
            barIcon: Icons.subscribe,
            swipeIcon1: isOn ? Icons.unsubscribePerson : Icons.subscribePerson,
            swipeIcon2: isOn ? Icons.unsubscribePersonFill : Icons.subscribePersonFill,
            callback: api.isAuthenticatedAndActive ? { self.self2?.toggleSubscribe(feedback: feedback) } : nil
        )
    }
    
    func favoriteAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.favorited ?? false
        return .init(
            id: "favorite\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Unfavorite" : "Favorite",
            color: Palette.main.favorite,
            icon: isOn ? Icons.unfavorite : Icons.favorite,
            barIcon: Icons.favorite,
            menuIcon: isOn ? Icons.favoriteFill : Icons.favorite,
            swipeIcon1: isOn ? Icons.unfavorite : Icons.favorite,
            swipeIcon2: isOn ? Icons.unfavoriteFill : Icons.favoriteFill,
            callback: api.isAuthenticatedAndActive ? { self.self2?.toggleFavorite(feedback: feedback) } : nil
        )
    }
    
    func blockAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "block\(uid)",
            isOn: false,
            label: blocked ? "Unblock" : "Block",
            color: Palette.main.negative,
            isDestructive: !blocked,
            confirmationPrompt: (!blocked && showConfirmation) ? "Really block this community?" : nil,
            icon: blocked ? Icons.show : Icons.hide,
            callback: api.isAuthenticatedAndActive ? { self.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
