//
//  FullyQualifiedNameView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import SwiftUI

struct FullyQualifiedNameView: View {
    @Environment(Palette.self) var palette
    
    let name: String
    let instance: String?
    
    // TODO: this PR
    // instance placement
    
    var body: some View {
        Text(name).bold().font(.footnote).foregroundStyle(palette.secondary) +
            Text("@" + (instance ?? "")).font(.footnote).foregroundStyle(palette.tertiary)
    }
}
