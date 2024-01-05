//
//  CollapsedCommentReplies.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-04.
//

import SwiftUI

struct CollapsedCommentReplies: View {
    @Binding var numberOfReplies: Int
    
    var body: some View {
        let replyText = numberOfReplies != 1 ? "comments" : "comment"

        HStack {
            Rectangle()
                .frame(width: 40, alignment: .leading)
                .background(.white)
            Image(systemName: Icons.replies)
            Text("\(numberOfReplies) \(replyText)")
        }
    }
}

#Preview {
    CollapsedCommentReplies(numberOfReplies: .constant(99))
}
