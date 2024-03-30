//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

struct Action {
    var label: String
    var barIsOn: Bool
    var barIcon: String
    var menuIcon: String
    var swipeIcon: String
    var swipeIcon2: String
    var color: Color
    var callback: (() -> Void)?
    
    init(
        label: String,
        enabled: Bool = true,
        barIsOn: Bool = false,
        barIcon: String,
        menuIcon: String,
        swipeIcon: String,
        swipeIcon2: String,
        color: Color = .clear,
        callback: (() -> Void)? = nil
    ) {
        self.label = label
        self.barIsOn = barIsOn
        self.barIcon = barIcon
        self.menuIcon = menuIcon
        self.swipeIcon = swipeIcon
        self.swipeIcon2 = swipeIcon2
        self.color = color
        self.callback = enabled ? callback : nil
    }
}
