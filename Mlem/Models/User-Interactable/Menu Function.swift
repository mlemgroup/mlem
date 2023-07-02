//
//  Menu Functions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-30.
//

import Foundation

/**
 All the info needed to populate a menu
 */
struct MenuFunction: Identifiable {
    var id: String { text }
    
    let text: String
    let imageName: String
    let destructiveActionPrompt: String?
    let enabled: Bool
    let callback: () -> Void
}
