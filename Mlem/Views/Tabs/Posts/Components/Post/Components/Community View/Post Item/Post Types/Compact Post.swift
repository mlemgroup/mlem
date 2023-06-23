//
//  Compact Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import CachedAsyncImage
import Foundation
import SwiftUI

struct CompactPost: View {
    // app storage
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 8 // constant for readability, ease of modification
    
    // arguments
    let postView: APIPostView
    let account: SavedAccount
    let voteOnPost: (ScoringOperation) async -> Void
    
    @State private var isShowingEnlargedImage: Bool = false
    @State private var dragOffset = CGSize.zero
    @State private var zoomScale: CGFloat = 1.0
    
    // computed
    var usernameColor: Color {
        if postView.creator.admin {
            return .red
        }
        if postView.creator.botAccount {
            return .indigo
        }
        
        return .secondary
    }
    
    var showNsfwFilter: Bool { postView.post.nsfw && shouldBlurNsfw }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack(alignment: .top) {
                thumbnailImage
                
                VStack(spacing: 2) {
                    Text(postView.post.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.trailing)
                    
                    HStack(spacing: 4) {
                        // stickied
                        if postView.post.featuredLocal { StickiedTag(compact: true) }
                        if postView.post.nsfw { NSFWTag(compact: true) }
                        
                        // community name
                        NavigationLink(destination: CommunityView(account: account, community: postView.community, feedType: .all)) {
                            Text(postView.community.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        Text("by")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        // poster
                        NavigationLink(destination: UserView(userID: postView.creator.id, account: account)) {
                            Text(postView.creator.name)
                                .font(.caption)
                                .italic()
                                .foregroundColor(usernameColor)
                        }
                        
                        Spacer()
                    }
                }
                
            }
            PostInteractionBar(postView: postView, account: account, compact: true, voteOnPost: voteOnPost)
        }
        .padding(spacing)
    }
    
    @ViewBuilder
    private var thumbnailImage: some View {
        Group {
            switch postView.postType {
            case .image(let url):
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: showNsfwFilter ? 8 : 0) // blur nsfw
                        .onTapGesture { isShowingEnlargedImage.toggle() }
                        .onChange(of: isShowingEnlargedImage) { newValue in
                            if newValue == false
                            {
                                withAnimation {
                                    dragOffset = .zero
                                    zoomScale = 1.0
                                }
                            }
                        }
                        .fullScreenCover(isPresented: $isShowingEnlargedImage, content: {
                            ZStack {
                                let dragDistance = sqrt(pow(dragOffset.width, 2) + pow(dragOffset.height, 2))
                                Color.black.opacity(max(0, 1 - Double(dragDistance / 500))).ignoresSafeArea() // Adjust opacity here
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(zoomScale)
                                    .offset(dragOffset)
                                    .gesture(
                                        DragGesture()
                                            .onChanged{gesture in
                                                dragOffset = gesture.translation}
                                            .onEnded{ value in
                                                withAnimation{
                                                    if abs(value.predictedEndTranslation.width) > 100 || abs(value.predictedEndTranslation.height) > 100
                                                    {
                                                        isShowingEnlargedImage = false
                                                        dragOffset = .zero
                                                    } else
                                                    {
                                                        dragOffset = .zero
                                                    }
                                                }
                                            }
                                            .simultaneously(with: MagnificationGesture().onChanged { scale in
                                                zoomScale = scale
                                            }.onEnded{ _ in
                                                withAnimation {
                                                    zoomScale = 1.0
                                                }
                                            })
                                    )
                                
                                
                            }
                        })
                } placeholder: {
                    ProgressView()
                }
            case .link(let url):
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: showNsfwFilter ? 8 : 0) // blur nsfw
                } placeholder: {
                    Image(systemName: "safari")
                }
            case .text:
                Image(systemName: "text.book.closed")
            case .titleOnly:
                Image(systemName: "character.bubble")
            }
        }
        .foregroundColor(.secondary)
        .font(.title)
        .frame(width: thumbnailSize, height: thumbnailSize)
        .background(Color(UIColor.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
    }
}
