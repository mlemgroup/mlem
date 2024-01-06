//
//  CollapsedCommentReplies.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-04.
//

import SwiftUI

struct CollapsedCommentReplies: View {
    @Binding var numberOfReplies: Int
    var lineWidth: CGFloat = 2
    
    var body: some View {
        let replyText = numberOfReplies != 1 ? "comments" : "comment"

        HStack {
            Rectangle()
                .border(width: lineWidth, edges: [.leading], color: .green)
                .frame(width: lineWidth)
            Image(systemName: Icons.replies)
            Text("show \(numberOfReplies) \(replyText)")
                .foregroundStyle(.blue)
        }
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}

#Preview {
    CollapsedCommentReplies(numberOfReplies: .constant(1))
}
