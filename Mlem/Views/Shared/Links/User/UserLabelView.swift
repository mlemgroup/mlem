//
//  User Profile Label.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI

struct UserLabelView: View {
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    var user: UserModel
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides avatar according to value; otherwise uses system settings
    
    // Extra context about where the link is being displayed
    // to pick the correct flair
    @State var postContext: APIPost?
    @State var commentContext: APIComment?
    @State var communityContext: GetCommunityResponse?
    
    var blurAvatar: Bool { postContext?.nsfw ?? false ||
        communityContext?.communityView.community.nsfw ?? false
    }
    
    @available(*, deprecated, message: "Provide a UserModel rather than an APIPerson.")
    init(
        person: APIPerson,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil,
        communityContext: GetCommunityResponse? = nil
    ) {
        self.init(
            user: UserModel(from: person),
            serverInstanceLocation: serverInstanceLocation,
            overrideShowAvatar: overrideShowAvatar,
            postContext: postContext,
            commentContext: commentContext,
            communityContext: communityContext
        )
    }
    
    init(
        user: UserModel,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil,
        communityContext: GetCommunityResponse? = nil
    ) {
        self.user = user
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        
        _postContext = State(initialValue: postContext)
        _commentContext = State(initialValue: commentContext)
        _communityContext = State(initialValue: communityContext)
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
        HStack(alignment: .center, spacing: AppConstants.largeAvatarSpacing) {
            if showAvatar {
                AvatarView(user: user, avatarSize: avatarSize, blurAvatar: blurAvatar)
                    .accessibilityHidden(true)
            }
            userName
        }
    }
    
    @ViewBuilder
    private var userName: some View {
        let flairs = user.getFlairs(
            postContext: postContext,
            commentContext: commentContext,
            communityContext: communityContext
        )
        
        HStack(spacing: 4) {
            if serverInstanceLocation == .bottom {
                if flairs.count == 1, let first = flairs.first {
                    userFlairIcon(with: first)
                        .imageScale(.large)
                } else if !flairs.isEmpty {
                    HStack(spacing: 2) {
                        LazyHGrid(rows: [GridItem(), GridItem()], alignment: .center) {
                            ForEach(flairs.dropLast(flairs.count % 2), id: \.self) { flair in
                                userFlairIcon(with: flair)
                                    .imageScale(.medium)
                            }
                        }
                        if flairs.count % 2 != 0 {
                            userFlairIcon(with: flairs.last!)
                                .imageScale(.medium)
                        }
                    }
                    .padding(2)
                    .padding(.trailing, 4)
                }
        
            } else {
                if flairs.count == 1, let first = flairs.first {
                    userFlairIcon(with: first)
                        .imageScale(.small)
                } else if !flairs.isEmpty {
                    ForEach(flairs, id: \.self) { flair in
                        userFlairIcon(with: flair)
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
    private func userFlairIcon(with flair: UserFlair) -> some View {
        Image(systemName: flair.icon)
            .bold()
            .font(.footnote)
            .foregroundColor(flair.color)
    }
    
    @ViewBuilder
    private func userName(with flairs: [UserFlair]) -> some View {
        Text(user.displayName)
            .bold()
            .font(.footnote)
            .foregroundColor(flairs.count == 1 ? flairs.first!.color : .gray)
    }
    
    @ViewBuilder
    private var userInstance: some View {
        if let host = user.profileUrl.host() {
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
    
    struct UserLinkViewFlair {
        var color: Color
        var image: Image?
    }
}
    
// TODO: darknavi - Move these to a common area for reuse
struct UserLinkViewPreview: PreviewProvider {
    // Only Admin and Bot work right now
    // Because the rest require post/comment context
    enum PreviewUserType: String, CaseIterable {
        case normal
        case mod
        case op
        case bot
        case admin
        case dev = "developer"
    }
    
    static func generatePreviewUser(name: String, displayName: String, userType: PreviewUserType) -> APIPerson {
        let actorId: URL
        if userType == .dev {
            actorId = URL(string: "http://\(UserModel.developerNames[0])")!
        } else {
            actorId = URL(string: "http://lemmy.ml/u/ericbandrews")!
        }
        
        return APIPerson(
            id: name.hashValue,
            name: name,
            displayName: displayName,
            avatar: nil,
            banned: false,
            published: Date.now.advanced(by: -120_000),
            updated: nil,
            actorId: actorId,
            bio: nil,
            local: false,
            banner: nil,
            deleted: false,
            sharedInboxUrl: nil,
            matrixUserId: nil,
            admin: userType == .admin,
            botAccount: userType == .bot,
            banExpires: nil,
            instanceId: 123
        )
    }
    
    static func generatePreviewComment(creator: APIPerson, isMod: Bool) -> APIComment {
        APIComment(
            id: 0,
            creatorId: creator.id,
            postId: 0,
            content: "",
            removed: false,
            deleted: false,
            published: Date.now,
            updated: nil,
            apId: "foo.bar",
            local: false,
            path: "foo",
            distinguished: isMod,
            languageId: 0
        )
    }
    
    static func generatePreviewPost(creator: APIPerson) -> PostModel {
        let community: APICommunity = .mock(id: 123, name: "Test Community")
        let post: APIPost = .mock(
            id: 123,
            name: "Test Post Title",
            body: "This is a test post body",
            creatorId: creator.id,
            communityId: 123,
            embedDescription: "Embedded Description",
            embedTitle: "Embedded Title"
        )
        
        let postVotes = APIPostAggregates(
            id: 123,
            postId: post.id,
            comments: 0,
            score: 10,
            upvotes: 15,
            downvotes: 5,
            published: Date.now,
            newestCommentTime: Date.now,
            newestCommentTimeNecro: Date.now,
            featuredCommunity: false,
            featuredLocal: false
        )
        
        return PostModel(from: APIPostView(
            post: post,
            creator: creator,
            community: community,
            creatorBannedFromCommunity: false,
            counts: postVotes,
            subscribed: .notSubscribed,
            saved: false,
            read: false,
            creatorBlocked: false,
            unreadComments: 0
        ))
    }
    
    static func generateUserLinkView(
        name: String,
        userType: PreviewUserType,
        serverInstanceLocation: ServerInstanceLocation
    ) -> UserLinkView {
        let previewUser = generatePreviewUser(name: name, displayName: name, userType: userType)
        
        var postContext: APIPost?
        var commentContext: APIComment?
        
        if userType == .mod {
            commentContext = generatePreviewComment(creator: previewUser, isMod: true)
        }
        
        if userType == .op {
            commentContext = generatePreviewComment(creator: previewUser, isMod: false)
            postContext = generatePreviewPost(creator: previewUser).post
        }
        
        return UserLinkView(
            user: UserModel(from: previewUser),
            serverInstanceLocation: serverInstanceLocation,
            postContext: postContext,
            commentContext: commentContext
        )
    }
    
    static var previews: some View {
        VStack {
            ForEach(ServerInstanceLocation.allCases, id: \.rawValue) { serverInstanceLocation in
                Spacer()
                ForEach(PreviewUserType.allCases, id: \.rawValue) { userType in
                    generateUserLinkView(name: "\(userType)User", userType: userType, serverInstanceLocation: serverInstanceLocation)
                }
            }
        }
    }
}
