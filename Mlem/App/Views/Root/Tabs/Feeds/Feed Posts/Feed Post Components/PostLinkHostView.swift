//
//  PostLinkHostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-26.
//

import Foundation
import SwiftUI

struct PostLinkHostView: View {
    @Environment(Palette.self) var palette
    
    let host: String?
    
    var body: some View {
        if let host {
            Group {
                Text(Image(systemName: Icons.browser)) +
                    Text(" \(host)")
            }
            .imageScale(.small)
            .foregroundStyle(palette.secondary)
        }
    }
}
