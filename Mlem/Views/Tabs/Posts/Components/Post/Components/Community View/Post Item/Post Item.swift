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
    let communityID: Int
    
    var url: String?
    var postBody: String? // Has to be
    let imageThumbnail: String?
    
    let urlToPost: String
    
    let score: Int
    
    let numberOfComments: Int
    
    let timePosted: String
    
    let isStickied: Bool
    
    let isExpanded: Bool
    
    let iconToTextSpacing: CGFloat = 2
    
    @EnvironmentObject var isInSpecificCommunity: IsInSpecificCommunity
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if !isExpanded { // Show this when the post is just in the list and not expanded
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if !isInSpecificCommunity.isInSpecificCommunity {
                                    NavigationLink(destination: Community_View(communityName: communityName, communityID: communityID)) {
                                        Text(communityName)
                                    }
                                    .buttonStyle(.plain)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }
                                
                                if isStickied {
                                    Stickied_Tag()
                                }
                            }
                            
                            Text(postName)
                                .font(.subheadline)
                        }
                    } else { // Show this when the post is expanded
                        Text(postName)
                            .font(.headline)
                        
                        if isStickied { // TODO: Make it look the right way when the post is expanded
                            Stickied_Tag()
                        }
                    }
                }
                
                if isStickied && !isExpanded { // If the text is stickied, only show the title. If the user expands the stickied post, make sure it actually has content
                    
                } else {
                    if postBody == nil { // First, if there's nothing in the body, it means it's not a normal text post, so...
                        if imageThumbnail != nil { // Show an image if there is no text in the body. But only show it if there actually is one.
                            AsyncImage(url: URL(string: imageThumbnail!), content: { image in
                                // TODO: Make it pull the image only at first. Don't pull it again when the post is opened
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        // TODO: Make it so that tapping an image makes it big
                                    }
                            }, placeholder: {
                                Loading_View(whatIsLoading: .image)
                            })
                            if url != nil { // Sometimes, these pictures are just links to other sites. If that's the case, add the link under the picture
                                Text(.init(url!))
                                    .dynamicTypeSize(.small)
                            }
                        } else if url != nil { // Second option is that it's a post with just a link and no body. Then just show the link
                            // TODO: Make the text look nicer. Maybe something like iMessage has when you send a link
                            Text(.init(url!))
                        } else { // I have no idea why this would happen
                            Text("ERR: Unexpected post format")
                        }
                        
                    } else { // Third option is it being a text post. Show that text here.
                        if isExpanded {
                            Text(.init(postBody!)) // .init for Markdown support
                                .dynamicTypeSize(.small)
                                .padding(.top, 2)
                        } else {
                            Text(.init(postBody!)) // .init for Markdown support
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(.small)
                                .lineLimit(3)
                                .padding(.top, 2)
                        }
                    }
                }
            }
            .padding()

            HStack {
                // TODO: Refactor this into Post Interactions once I learn how to pass the vars further down
                HStack(alignment: .center) {
                    Upvote_Button(score: score)
                    Downvote_Button()
                    Share_Button(urlToShare: urlToPost)
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
                        Text(getTimeIntervalFromNow(originalTime: timePosted))
                    }
                    
                    User_Profile_Link(userName: author)
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
                print("\(communityID)")
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

