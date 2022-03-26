//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Item: View {
    let postName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) { // TODO: Make it so that tapping this VStack takes the user to the post detail
                HStack {
                    Text(postName)
                        .font(.subheadline)
                }
                .padding(.leading)
                .padding(.trailing)
                
                Image("Sleeping Lions")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .onTapGesture {
                print("I would take you to the detail view")
            }
            
            HStack(alignment: .center) {
                Upvote_Button()
                Downvote_Button()
                Share_Button()
            }
            .padding()
        }
        .padding(.top)
        .background(Color.systemBackground)
        .contextMenu { // This created that "peek and pop" feel that I used to love
            // TODO: Implement Peek and pop behavior for posts
            Button("Hello") {
                
            }
            Divider()
            Button("This is me") {
                
            }
        }
    }
}

