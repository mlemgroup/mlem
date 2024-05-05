//
//  Community2Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/05/2024.
//

import Foundation
import MlemMiddleware

extension Community2Providing {
    var subscribeAction: BasicAction {
        .subscribe(isOn: subscribed, callback: api.willSendToken ? toggleSubscribe : nil)
    }
    
    var favoriteAction: BasicAction {
        .favorite(isOn: favorited, callback: api.willSendToken ? toggleFavorite : nil)
    }
}
