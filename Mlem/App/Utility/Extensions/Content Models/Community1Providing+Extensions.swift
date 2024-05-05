//
//  Community1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/05/2024.
//

import Foundation
import MlemMiddleware

extension Community1Providing {
    var subscribeAction: BasicAction {
        .subscribe(isOn: false)
    }
    
    var favoriteAction: BasicAction {
        .favorite(isOn: false)
    }
}
