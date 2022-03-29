//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Item: View {
    let postName: String
    let author: String
    
    let communityName: String
    let communityLink: String
    
    let postBody: String?
    let imageThumbnail: String?
    
    let score: Int
    
    let numberOfComments: Int
    
    let iconToTextSpacing: CGFloat = 2
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) { // TODO: Make it so that tapping this VStack takes the user to the post detail
                HStack {
                    Text(postName)
                        .font(.subheadline)
                }
                
                if postBody == nil { // Show an image if there is no text in the body
                    if imageThumbnail != nil { // Only show the image if there actually is one. Otherwise just don't show anything
                        AsyncImage(url: URL(string: imageThumbnail!), content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    // TODO: Make it so that tapping an image makes it big
                                }
                        }, placeholder: {
                            ProgressView()
                        })
                    } else {
                        Text("ERROR: Wtf is this post format")
                            .background(.red)
                    }
                    
                } else { // Otherwise show the text
                    Text(postBody!)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small)
                        .lineLimit(3)
                        .padding(.top, 2)
                }
            }
            .padding()

            HStack {
                // TODO: Refactor this into Post Interactions once I learn how to pass the vars further down
                HStack(alignment: .center) {
                    HStack(spacing: iconToTextSpacing) {
                        Upvote_Button()
                        Text(String(score))
                            .foregroundColor(.blue)
                    }
                    Downvote_Button()
                    Share_Button()
                }
                
                Spacer()
                
                // TODO: Refactor this into Post Info once I learn how to pass the vars further down
                HStack(spacing: 8) {
                    /*HStack(spacing: iconToTextSpacing) { // Number of upvotes
                        Image(systemName: "arrow.up")
                        Text(String(score))
                    }*/
                    
                    HStack(spacing: iconToTextSpacing) { // Number of comments
                        Image(systemName: "bubble.left")
                        Text(String(numberOfComments))
                    }
                    
                    HStack(spacing: iconToTextSpacing) { // Time since posted
                        Image(systemName: "clock")
                        Text("3h")
                    }
                    
                    Text(author)
                }
                .foregroundColor(.secondary)
                .dynamicTypeSize(.small)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.systemBackground)
        .contextMenu { // This created that "peek and pop" feel that I used to love
            // TODO: Implement Peek and pop behavior for posts
            Button(action: {
                // TODO: Make saving posts work
            }, label: {
                Label("Save", systemImage: "bookmark.fill")
            })
            
            Button {
                // TODO: Make going to communities work
                print("\(communityLink)")
            } label: {
                Label("c/\(communityName)", systemImage: "person.3.fill")
            }
            
            Divider()
            Button {
                // TODO: Make going to people work
                print("Take me to \(author)")
            } label: {
                Label(author, systemImage: "person.circle.fill")
            }

        }
    }
}

