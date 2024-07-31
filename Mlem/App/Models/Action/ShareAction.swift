//
//  BasicAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI

struct ShareAction: Action {
    let id: String
    let url: URL

    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
    
    var label: String { String(localized: "Share...") }
    var isDestructive: Bool { false }
    var color: Color { .gray }
    var isOn: Bool { false }
    var barIcon: String { Icons.share }
    var menuIcon: String { Icons.share }
    var swipeIcon1: String { Icons.share }
    var swipeIcon2: String { Icons.share }
}
