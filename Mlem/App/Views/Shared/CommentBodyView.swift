//
//  CommentBodyView.swift
//  Mlem
//
//  Created by Sjmarf on 09/08/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommentBodyView: View {
    @Environment(Palette.self) var palette
    
    let comment: any Comment
    
    var body: some View {
        if comment.deleted {
            Text("Comment was deleted")
                .italic()
                .foregroundStyle(palette.secondary)
        } else if comment.removed {
            Text("Comment was removed")
                .italic()
                .foregroundStyle(palette.secondary)
        } else {
            Markdown(comment.content, configuration: .default)
        }
    }
}
