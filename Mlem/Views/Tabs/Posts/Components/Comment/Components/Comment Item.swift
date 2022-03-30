//
//  Comment View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Comment_Item: View {
    let author: String?
    
    let commentBody: String
    
    let commentID: Int // Here to make replying possible. DON'T REMOVE
    
    let score: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.init(commentBody)) // .init makes the comments have Markdown support
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            HStack(spacing: 12) {
                HStack {
                    Upvote_Button(score: score)
                    Downvote_Button()
                }
                HStack(spacing: 3) {
                    Button(action: {
                        print("Would reply to comment ID \(score)")
                    }, label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    })
                    
                    Text("Reply")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(author ?? .init("ERR: Unable to decode username"))
                    .foregroundColor(.secondary)
            }
        }
        .dynamicTypeSize(.small)
    }
}
