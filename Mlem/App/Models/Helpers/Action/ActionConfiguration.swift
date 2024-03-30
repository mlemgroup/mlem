//
//  ActionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

protocol ActionConfiguration {
    var type: ActionType { get }
    var isOn: Bool { get }
    
    var label: String { get }
    var color: Color { get }
    
    var barIcon: String { get }
    var menuIcon: String { get }
    var swipeIcon1: String { get }
    var swipeIcon2: String { get }
}

struct BasicActionConfiguration: ActionConfiguration {
    let type: ActionType
    let isOn: Bool
    
    let label: String
    let color: Color
    
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
}
