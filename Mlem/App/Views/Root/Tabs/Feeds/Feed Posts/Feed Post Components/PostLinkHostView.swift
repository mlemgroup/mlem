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
    
    let host: String
    
    var body: some View {
        content
            .lineLimit(1)
            .imageScale(.small)
            .foregroundStyle(palette.secondary)
    }
    
    var content: Text {
        Text(Image(systemName: Icons.browser)) + Text(verbatim: " \(host)")
    }
}
