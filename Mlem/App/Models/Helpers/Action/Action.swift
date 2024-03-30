//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

protocol Action {
    associatedtype Configuration: ActionConfiguration
    var configuration: Configuration { get }
}

struct BasicAction: Action {
    typealias Configuration = BasicActionConfiguration
    
    let configuration: BasicActionConfiguration
    
    /// If this is nil, the Action is disabled
    let callback: (() -> Void)?
    
    init(
        configuration: Configuration,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.callback = enabled ? callback : nil
    }
    
    var type: ActionType { configuration.type }
    var isOn: Bool { configuration.isOn }
    var label: String { configuration.label }
    var color: Color { configuration.color }
    
    var barIcon: String { configuration.barIcon }
    var menuIcon: String { configuration.menuIcon }
    var swipeIcon1: String { configuration.swipeIcon1 }
    var swipeIcon2: String { configuration.swipeIcon2 }
}
