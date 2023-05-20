//
//  Comment View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct CommentItem: View
{
    
    @State var comment: Comment
    @State var isCollapsed = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            if !isCollapsed
            {
                MarkdownView(text: comment.content)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            HStack(spacing: 12)
            {
                HStack
                {
                    UpvoteButton(score: comment.score)
                    DownvoteButton()
                }
                HStack(spacing: 4)
                {
                    Button(action: {
                        print("Would reply to comment ID \(comment.id)")
                    }, label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    })

                    Text("Reply")
                        .foregroundColor(.accentColor)
                }

                Spacer()

                HStack
                {
                    Text(getTimeIntervalFromNow(date: comment.published))
                    UserProfileLink(user: comment.author)
                }
                .foregroundColor(.secondary)
            }
            
            Divider()

            if !isCollapsed
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    ForEach(comment.children)
                    { comment in
                        CommentItem(comment: comment)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .clipped()
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture
        {
            withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
            {
                isCollapsed.toggle()
            }
        }
        .dynamicTypeSize(.small)
        .background(Color.systemBackground)
        .padding(comment.parentID == nil ? .horizontal : .leading)
    }
}
