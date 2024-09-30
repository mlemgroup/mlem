//
//  BasicAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI
import UIKit

struct ShareAction: Action {
    let id: String
    let url: URL
    let actions: [BasicAction]

    init(id: String, url: URL, actions: [BasicAction] = []) {
        self.id = id
        self.url = url
        self.actions = actions
    }
    
    var appearance: ActionAppearance { .share() }
}
