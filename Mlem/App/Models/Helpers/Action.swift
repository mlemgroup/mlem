//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

struct Action {
    let type: ActionType
    let isOn: Bool
    
    /// If this is nil, the Action is disabled
    let callback: (() -> Void)?
    
    init(
        type: ActionType,
        isOn: Bool,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.type = type
        self.isOn = isOn
        self.callback = enabled ? callback : nil
    }
    
    var label: String { type.label(isOn) }
    var color: Color { type.color }
    var barIcon: String { type.barIcon(isOn: isOn) }
    var menuIcon: String { type.menuIcon(isOn: isOn) }
    var swipeIcon1: String { type.swipeIcon1(isOn: isOn) }
    var swipeIcon2: String { type.swipeIcon2(isOn: isOn) }
}
