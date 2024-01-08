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
        HStack {
            Rectangle()
                .border(width: lineWidth, edges: [.leading], color: .accentColor)
                .frame(width: lineWidth)
            Image(systemName: Icons.replies)
            Text("Show ^[\(numberOfReplies) Reply](inflect: true)")
                .foregroundStyle(.blue)
                .padding(.vertical, 10)
        }
        .frame(maxHeight: 50)
        .padding(.leading, 10)
    }
}

#Preview {
    CollapsedCommentReplies(numberOfReplies: .constant(1))
}
