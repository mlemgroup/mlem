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

    @State private var isShowingReplySheet = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            HStack(alignment: .center, spacing: 10) {
                if comment.parentID != nil
                {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.red)
                        .frame(width: 2)
                }
                
                Text(.init(comment.content)) // .init makes the comments have Markdown support
                    .frame(maxWidth: .infinity, alignment: .topLeading)
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
                        isShowingReplySheet.toggle()
                    }, label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    })

                    Text("Reply")
                        .foregroundColor(.accentColor)
                }

                Spacer()

                HStack
                {
                    Text(getTimeIntervalFromNow(date: convertResponseDateToDate(responseDate: comment.published)))
                    UserProfileLink(user: comment.author)
                }
                .foregroundColor(.secondary)
            }
            
            Divider()

            VStack(alignment: .leading, spacing: 10) {
                ForEach(comment.children) { comment in
                    CommentItem(comment: comment)
                }
            }
        }
        .dynamicTypeSize(.small)
        .sheet(isPresented: $isShowingReplySheet)
        {
            ReplyView(parentComment: comment)
        }
        .padding(comment.parentID == nil ? .horizontal : .leading)
    }
}
