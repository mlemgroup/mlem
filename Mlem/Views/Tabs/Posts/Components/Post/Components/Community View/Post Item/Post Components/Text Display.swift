//
//  Text Display.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation
import SwiftUI

struct TextDisplay: View {
    let postBody: String
    let isExpanded: Bool
    
    var body: some View {
        if !postBody.isEmpty {
            Group {
                if isExpanded {
                    MarkdownView(text: postBody)
                } else {
                    MarkdownView(text: postBody.components(separatedBy: .newlines).joined())
                        .lineLimit(8)
                }
            }.font(.subheadline)
        }
    }
}
