//
//  BasicAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import Dependencies
import SwiftUI

struct BasicAction: Action {
    let id: String
    let isOn: Bool
    
    let label: String
    let isDestructive: Bool
    let color: Color
    
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
    
    /// If this is nil, the BasicAction is disabled
    var callback: (() -> Void)?
    
    var disabled: Bool { callback == nil }
    
    /// - Parameter id: This must be unique to the action AND contain the model's unique ID.
    /// If you don't do this, SwiftUI can get confused in a lazy view.
    init(
        id: String,
        isOn: Bool,
        label: String,
        color: Color,
        isDestructive: Bool = false,
        icon: String,
        barIcon: String? = nil,
        menuIcon: String? = nil,
        swipeIcon1: String? = nil,
        swipeIcon2: String? = nil,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.id = id
        self.isOn = isOn
        self.label = label
        self.isDestructive = isDestructive
        self.color = color
        self.barIcon = barIcon ?? icon
        self.menuIcon = menuIcon ?? icon
        self.swipeIcon1 = swipeIcon1 ?? icon
        self.swipeIcon2 = swipeIcon2 ?? icon
        self.callback = enabled ? callback : nil
    }
}
