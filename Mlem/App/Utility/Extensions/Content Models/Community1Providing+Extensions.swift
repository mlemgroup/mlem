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
    
    var subscribeAction: BasicAction {
        let isOn: Bool = self2?.subscribed ?? false
        return .init(
            id: "subscribe\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Unsubscribe" : "Subscribe",
            color: isOn ? .green : .red,
            icon: isOn ? Icons.unsubscribe : Icons.subscribe,
            barIcon: Icons.subscribe,
            swipeIcon1: isOn ? Icons.unsubscribePerson : Icons.subscribePerson,
            swipeIcon2: isOn ? Icons.unsubscribePersonFill : Icons.subscribePersonFill,
            callback: api.willSendToken ? self2?.toggleSubscribe : nil
        )
    }
    
    var favoriteAction: BasicAction {
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
            callback: api.willSendToken ? self2?.toggleFavorite : nil
        )
    }
}
