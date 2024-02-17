//
//  User Profile Label.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI

struct PersonLabelView: View {
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    let person: any Person
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides avatar according to value; otherwise uses system settings
    
    // Extra context about where the link is being displayed
    // to pick the correct flair
    let postContext: (any Post)?
    let commentContext: APIComment?
    let communityContext: (any Community)?
    
    var blurAvatar: Bool { postContext?.nsfw ?? false ||
        communityContext?.nsfw ?? false
    }
    
    init(
        person: any Person,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: (any Post)? = nil,
        commentContext: APIComment? = nil,
        communityContext: (any Community)? = nil
    ) {
        self.person = person
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        
        self.postContext = postContext
        self.commentContext = commentContext
        self.communityContext = communityContext
    }
    
    var showAvatar: Bool {
        if let overrideShowAvatar {
            return overrideShowAvatar
        } else {
            return shouldShowUserAvatars
        }
    }
    
    var avatarSize: CGFloat { serverInstanceLocation == .bottom ? AppConstants.largeAvatarSize : AppConstants.smallAvatarSize }

    var body: some View {
        HStack(
            alignment: .center,
            spacing: serverInstanceLocation == .bottom ? AppConstants.largeAvatarSpacing : 8
        ) {
            if showAvatar {
                AvatarView(person: person, avatarSize: avatarSize, blurAvatar: blurAvatar)
                    .accessibilityHidden(true)
            }
            userName
        }
    }
    
    @ViewBuilder
    private var userName: some View {
        let flairs = person.getFlairs(
            postContext: postContext,
            // commentContext: commentContext,
            communityContext: communityContext
        )
        
        HStack(spacing: 4) {
            if serverInstanceLocation == .bottom {
                if flairs.count == 1, let first = flairs.first {
                    flairIcon(with: first)
                        .imageScale(.large)
                } else if !flairs.isEmpty {
                    HStack(spacing: 2) {
                        LazyHGrid(rows: [GridItem(), GridItem()], alignment: .center, spacing: 2) {
                            ForEach(flairs.dropLast(flairs.count % 2), id: \.self) { flair in
                                flairIcon(with: flair)
                                    .imageScale(.medium)
                            }
                        }
                        if flairs.count % 2 != 0 {
                            flairIcon(with: flairs.last!)
                                .imageScale(.medium)
                        }
                    }
                    .padding(.trailing, 4)
                }
        
            } else {
                if flairs.count == 1, let first = flairs.first {
                    flairIcon(with: first)
                        .imageScale(.small)
                } else if !flairs.isEmpty {
                    ForEach(flairs, id: \.self) { flair in
                        flairIcon(with: flair)
                            .imageScale(.small)
                    }
                    .padding(.trailing, 4)
                }
            }
            
            switch serverInstanceLocation {
            case .disabled:
                userName(with: flairs)
            case .bottom:
                VStack(alignment: .leading) {
                    userName(with: flairs)
                    userInstance
                }
            case .trailing:
                HStack(spacing: 0) {
                    userName(with: flairs)
                    userInstance
                }
            }
        }
    }
    
    @ViewBuilder
    private func flairIcon(with flair: PersonFlair) -> some View {
        Image(systemName: flair.icon)
            .bold()
            .font(.footnote)
            .foregroundColor(flair.color)
    }
    
    @ViewBuilder
    private func userName(with flairs: [PersonFlair]) -> some View {
        Text(person.displayName ?? person.name)
            .bold()
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var userInstance: some View {
        if let host = person.host {
            Text("@\(host)")
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .font(.caption)
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
}
