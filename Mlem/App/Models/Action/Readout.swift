//
//  Readout.swift
//  Mlem
//
//  Created by Sjmarf on 16/06/2024.
//

import SwiftUI
import Icons
import Theming

struct Readout {
    let id: String
    let label: String?
    let icon: Icon
    var color: ThemedColor?
    var value: String?
    var valueColor: ThemedColor?
}
