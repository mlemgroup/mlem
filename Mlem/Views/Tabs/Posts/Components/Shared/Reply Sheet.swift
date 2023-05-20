//
//  Reply Sheet.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import SwiftUI

struct ReplySheet: View
{
    @Binding var isShowingSheet: Bool

    var post: Post
    var account: SavedAccount

    @State private var replyText: String = ""
    @State private var cursorPosition: Int = 0

    @FocusState var isReplyFieldFocused

    var body: some View
    {
        NavigationView {
            VStack(alignment: .leading, spacing: 0)
            {
                HStack(alignment: .center, spacing: 10)
                {
                    Spacer()
                    
                    Button
                    {
                        isShowingSheet.toggle()
                    } label: {
                        Text("Close")
                    }
                }
                .padding()
                .background(.thinMaterial)
                
                Divider()
                
                /*
                 ScrollView
                 {
                 PostItem(post: post, isExpanded: true, isInSpecificCommunity: false, instanceAddress: account.instanceLink, account: account, isPostCollapsed: true)
                 }
                 */
                
                Button {
                    print("Would send \(replyText)")
                } label: {
                    Text("Send")
                }
                
                
                ReplyEditor(text: $replyText)
            }
        }
        .navigationTitle("Some Text").toolbar {
            ToolbarItemGroup(placement: .keyboard)
            {
                Spacer()
                Button {
                    print("Ahoj")
                } label: {
                    Text("Ahoj")
                }
                
            }
        }
    }
}
