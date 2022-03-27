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
                
                Image("Sleeping Lions")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            .onTapGesture {
                print("I would take you to the detail view")
            }
            
            HStack {
                Post_Interactions()
                Spacer()
                Post_Info()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.systemBackground)
        .contextMenu { // This created that "peek and pop" feel that I used to love
            // TODO: Implement Peek and pop behavior for posts
            Button(action: {
                
            }, label: {
                Label("Save", systemImage: "bookmark.fill")
            })
            
            Divider()
            Button("This is me") {
                
            }
        }
    }
}

