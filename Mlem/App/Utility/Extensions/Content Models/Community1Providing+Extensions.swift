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
}
