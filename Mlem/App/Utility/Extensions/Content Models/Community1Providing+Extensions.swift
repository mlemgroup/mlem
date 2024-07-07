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
    
    func toggleSubscribe(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.toast) {
                let wasFavorited = self2.favorited
                if self2.subscribed {
                    ToastModel.main.add(
                        .undoable(
                            title: "Unsubscribed",
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
            if feedback.contains(.toast) {
                if self2.favorited {
                    ToastModel.main.add(
                        .undoable(
                            title: "Unfavorited",
                            systemImage: "star.slash.fill",
                            callback: {
                                self2.updateFavorite(true)
                            },
                            color: Palette.main.favorite
                        )
                    )
                } else {
                    ToastModel.main.add(
                        .basic(title: "Favorited", systemImage: "star.fill", color: .blue)
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
                    title: "Blocked",
                    systemImage: Icons.hideFill,
                    callback: {
                        self.updateBlocked(false)
                    },
                    color: Palette.main.negative
                )
            )
        }
        toggleBlocked()
    }
    
    func menuActions(feedback: Set<FeedbackType> = [.haptic]) -> ActionGroup {
        ActionGroup(
            children: [
                subscribeAction(feedback: feedback),
                favoriteAction(feedback: feedback)
            ]
        )
    }
    
    func subscribeAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.subscribed ?? false
        return .init(
            id: "subscribe\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Unsubscribe" : "Subscribe",
            color: isOn ? .green : .red,
            isDestructive: isOn,
            icon: isOn ? Icons.unsubscribe : Icons.subscribe,
            barIcon: Icons.subscribe,
            swipeIcon1: isOn ? Icons.unsubscribePerson : Icons.subscribePerson,
            swipeIcon2: isOn ? Icons.unsubscribePersonFill : Icons.subscribePersonFill,
            callback: api.willSendToken ? { self.self2?.toggleSubscribe(feedback: feedback) } : nil
        )
    }
    
    func favoriteAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.favorited ?? false
        return .init(
            id: "favorite\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Unfavorite" : "Favorite",
            color: .blue,
            icon: isOn ? Icons.unfavorite : Icons.favorite,
            barIcon: Icons.favorite,
            menuIcon: isOn ? Icons.favoriteFill : Icons.favorite,
            swipeIcon1: isOn ? Icons.unfavorite : Icons.favorite,
            swipeIcon2: isOn ? Icons.unfavoriteFill : Icons.favoriteFill,
            callback: api.willSendToken ? { self2?.toggleFavorite(feedback: feedback) } : nil
        )
    }
}
