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
            
            Text("\(parentCommentAuthor):")
                .dynamicTypeSize(.small)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(.init(parentCommentText))
                .dynamicTypeSize(.small)
                .font(.subheadline)
            
            TextEditor(text: $replyContent)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .border(Color.secondarySystemBackground, width: 2)
        }
        .padding()
    }
}
