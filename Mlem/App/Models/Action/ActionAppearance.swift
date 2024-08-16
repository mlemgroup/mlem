//
//  ActionAppearance.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import SwiftUI

struct ActionAppearance {
    let label: String
    let isOn: Bool
    let isDestructive: Bool
    let color: Color
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
    
    init(
        label: LocalizedStringResource,
        isOn: Bool = false,
        isDestructive: Bool = false,
        color: Color,
        icon: String,
        barIcon: String? = nil,
        menuIcon: String? = nil,
        swipeIcon1: String? = nil,
        swipeIcon2: String? = nil
    ) {
        self.init(
            label: .init(localized: label),
            isOn: isOn,
            isDestructive: isDestructive,
            color: color,
            icon: icon,
            barIcon: barIcon,
            menuIcon: menuIcon,
            swipeIcon1: swipeIcon1,
            swipeIcon2: swipeIcon2
        )
    }
    
    @_disfavoredOverload
    init(
        label: String,
        isOn: Bool = false,
        isDestructive: Bool = false,
        color: Color,
        icon: String,
        barIcon: String? = nil,
        menuIcon: String? = nil,
        swipeIcon1: String? = nil,
        swipeIcon2: String? = nil
    ) {
        self.label = label
        self.isOn = isOn
        self.isDestructive = isDestructive
        self.color = color
        self.barIcon = barIcon ?? icon
        self.menuIcon = menuIcon ?? icon
        self.swipeIcon1 = swipeIcon1 ?? icon
        self.swipeIcon2 = swipeIcon2 ?? icon
    }
}
