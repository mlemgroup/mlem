//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

protocol Action {
    var type: ActionType { get }
    var isOn: Bool { get }
    
    var label: String { get }
    var color: Color { get }
    
    var barIcon: String { get }
    var menuIcon: String { get }
    var swipeIcon1: String { get }
    var swipeIcon2: String { get }
}

struct BasicAction: Action {
    let type: ActionType
    let isOn: Bool
    
    let label: String
    let color: Color
    
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
    
    /// If this is nil, the Action is disabled
    var callback: (() -> Void)?
    
    init(
        type: ActionType,
        isOn: Bool,
        label: String,
        color: Color,
        barIcon: String,
        menuIcon: String,
        swipeIcon1: String,
        swipeIcon2: String,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.type = type
        self.isOn = isOn
        self.label = label
        self.color = color
        self.barIcon = barIcon
        self.menuIcon = menuIcon
        self.swipeIcon1 = swipeIcon1
        self.swipeIcon2 = swipeIcon2
        self.callback = enabled ? callback : nil
    }
}
