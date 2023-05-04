//
//  Comment View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Comment_Item: View
{
    
    @State var comment: Comment

    @State private var isShowingReplySheet = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            Text(.init(comment.content)) // .init makes the comments have Markdown support
                .frame(maxWidth: .infinity, alignment: .topLeading)

            HStack(spacing: 12)
            {
                HStack
                {
                    Upvote_Button(score: comment.score)
                    Downvote_Button()
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
                    Text(getTimeIntervalFromNow(originalTime: comment.published))
                    User_Profile_Link(userName: comment.creatorName)
                }
                .foregroundColor(.secondary)
            }
        }
        .dynamicTypeSize(.small)
        .sheet(isPresented: $isShowingReplySheet)
        {
            Reply_View(parentComment: comment)
        }
    }
}
