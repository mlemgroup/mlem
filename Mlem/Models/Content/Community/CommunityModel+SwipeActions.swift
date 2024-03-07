//
//  CommunityModel+SwipeActions.swift
//  Mlem
//
//  Created by Sjmarf on 10/11/2023.
//

import Foundation
import SwiftUI

extension CommunityModel {
    func subscribeSwipeAction(
        _ trackerCallback: @escaping (_ item: Self) -> Void = { _ in },
        menuFunctionPopup: Binding<MenuFunctionPopup?>
    ) throws -> SwipeAction {
        guard let subscribed else {
            throw CommunityError.noData
        }
        let (emptySymbolName, fullSymbolName) = subscribed
            ? (Icons.unsubscribePerson, Icons.unsubscribePersonFill)
            : (Icons.subscribePerson, Icons.subscribePersonFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: subscribed ? .red : .green,
            action: {
                hapticManager.play(haptic: .lightSuccess, priority: .low)
                let callback = {
                    Task {
                        do {
                            try await self.toggleSubscribe(trackerCallback)
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                    return ()
                }
                if subscribed {
                    menuFunctionPopup.wrappedValue = .init(
                        prompt: "Are you sure you want to unsubscribe from \(name!)?",
                        actions: [.init(text: "Yes", callback: callback)]
                    )
                } else {
                    callback()
                }
            }
        )
    }
    
    func favoriteSwipeAction(
        _ trackerCallback: @escaping (_ item: Self) -> Void = { _ in },
        menuFunctionPopup: Binding<MenuFunctionPopup?>
    ) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = favorited
            ? (Icons.unfavorite, Icons.unfavoriteFill)
            : (Icons.favorite, Icons.favoriteFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: favorited ? .red : .blue,
            action: {
                let callback = {
                    Task {
                        do {
                            try await self.toggleFavorite(trackerCallback)
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                    return ()
                }
                if favorited {
                    menuFunctionPopup.wrappedValue = .init(
                        prompt: "Are you sure you want to unfavorite \(name!)?",
                        actions: [.init(text: "Yes", callback: callback)]
                    )
                } else {
                    callback()
                }
            }
        )
    }
        
    func swipeActions(
        _ trackerCallback: @escaping (_ item: Self) -> Void = { _ in },
        menuFunctionPopup: Binding<MenuFunctionPopup?>
    ) -> SwipeConfiguration {
        var trailingActions: [SwipeAction] = []
        let subscribeAction = try? subscribeSwipeAction(trackerCallback, menuFunctionPopup: menuFunctionPopup)
        let favoriteAction = favoriteSwipeAction(trackerCallback, menuFunctionPopup: menuFunctionPopup)
        
        if let subscribeAction {
            trailingActions.append(subscribeAction)
            trailingActions.append(favoriteAction)
        }
       
        return SwipeConfiguration(leadingActions: [], trailingActions: trailingActions)
    }
}
