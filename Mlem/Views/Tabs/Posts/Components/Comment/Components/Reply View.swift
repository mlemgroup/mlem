//
//  Reply View.swift
//  Mlem
//
//  Created by David Bureš on 31.03.2022.
//

import SwiftUI

struct Reply_View: View {
    
    var parentCommentID: Int
    var parentCommentText: String
    var parentCommentAuthor: String
    
    @Environment(\.dismiss) var dismiss
    
    @State private var replyContent: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Reply")
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(parentCommentAuthor)
                    .foregroundColor(.secondary)
                Text(.init(parentCommentText))
                    .padding()
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
            }
            .dynamicTypeSize(.small)
            .font(.subheadline)
            .multilineTextAlignment(.leading)
            
            TextEditor(text: $replyContent)
                .lineSpacing(4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .border(Color.secondarySystemBackground, width: 2)
            
            Spacer()
        }
        .padding()
    }
}
