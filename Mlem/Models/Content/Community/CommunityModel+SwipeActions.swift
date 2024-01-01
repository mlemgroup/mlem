//
//  CommunityModel+SwipeActions.swift
//  Mlem
//
//  Created by Sjmarf on 10/11/2023.
//

import Foundation

extension CommunityModel {
    
    func subscribeSwipeAction(
        _ callback: @escaping (_ item: Self) -> Void = { _ in },
        confirmDestructive: ((StandardMenuFunction) -> Void)? = nil
    ) throws -> SwipeAction {
        guard let subscribed else {
            throw CommunityError.noData
        }
        let (emptySymbolName, fullSymbolName) = (subscribed)
        ? (Icons.unsubscribePerson, Icons.unsubscribePersonFill)
        : (Icons.subscribePerson, Icons.subscribePersonFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: subscribed ? .red : .green,
            action: {
                Task {
                    hapticManager.play(haptic: .lightSuccess, priority: .low)
                    
                    if subscribed, let confirmDestructive {
                        if let function = try? subscribeMenuFunction(callback) {
                            confirmDestructive(function)
                        }
                    } else {
                        var new = self
                        do {
                            try await new.toggleSubscribe(callback)
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
            }
        )
    }
    
    func favoriteSwipeAction(
        _ callback: @escaping (_ item: Self) -> Void = { _ in },
        confirmDestructive: ((StandardMenuFunction) -> Void)? = nil
    ) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = (favorited)
        ? (Icons.unfavorite, Icons.unfavoriteFill)
        : (Icons.favorite, Icons.favoriteFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: favorited ? .red : .blue,
            action: {
                Task {
                    hapticManager.play(haptic: .lightSuccess, priority: .low)
                    
                    if favorited, let confirmDestructive {
                        confirmDestructive(favoriteMenuFunction(callback))
                    } else {
                        var new = self
                        new.toggleFavorite(callback)
                    }
                }
            }
        )
    }
        
    func swipeActions(
        _ callback: @escaping (_ item: Self) -> Void = { _ in },
        confirmDestructive: ((StandardMenuFunction) -> Void)? = nil
    ) -> SwipeConfiguration {
        var trailingActions: [SwipeAction] = []
        if !self.favorited, let action = try? subscribeSwipeAction(callback, confirmDestructive: confirmDestructive) {
            trailingActions.append(action)
        }
        trailingActions.append(favoriteSwipeAction(callback, confirmDestructive: confirmDestructive))
        return SwipeConfiguration(leadingActions: [], trailingActions: trailingActions)
    }
}
