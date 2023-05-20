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

    @FocusState var isReplyFieldFocused

    var body: some View
    {
        NavigationView
        {
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
                
                ReplyEditor(text: $replyText)
                    
            }
        }
        .toolbar
        {
            ToolbarItem(placement: .keyboard) {
                Text("Ahoj")
            }
            /*
            ToolbarItemGroup(placement: .keyboard)
            {
                HStack(alignment: .center, spacing: 10)
                {
                    Button
                    {
                        print("Would make bold")
                    } label: {
                        Label("Insert bold text", systemImage: "bold")
                    }
                    
                    Spacer()
                    
                    Button
                    {
                        print("Would send reply")
                    } label: {
                        Label("Reply", systemImage: "paperplane")
                    }
                }
            }
             */
        }
    }
}
