//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

protocol Action: Identifiable {
    var id: String { get }
    var appearance: ActionAppearance { get }
}
