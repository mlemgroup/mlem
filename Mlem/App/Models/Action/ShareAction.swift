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
    
    var appearance: ActionAppearance { .share() }
}
