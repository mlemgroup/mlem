//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

protocol Action: Identifiable {
    var id: UUID { get }
    
    var isOn: Bool { get }
    
    var label: String { get }
    var isDestructive: Bool { get }
    var color: Color { get }
    
    var barIcon: String { get }
    var menuIcon: String { get }
    var swipeIcon1: String { get }
    var swipeIcon2: String { get }
}
