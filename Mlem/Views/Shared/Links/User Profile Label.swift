//
//  User Profile Label.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI
import CachedAsyncImage

struct UserProfileLabel: View {
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    var user: APIPerson
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides avatar according to value; otherwise uses system settings
    
    // Extra context about where the link is being displayed
    // to pick the correct flair
    @State var postContext: APIPost?
    @State var commentContext: APIComment?
    @State var communityContext: GetCommunityResponse?
    
    init(user: APIPerson,
         serverInstanceLocation: ServerInstanceLocation,
         overrideShowAvatar: Bool? = nil,
         postContext: APIPost? = nil,
         commentContext: APIComment? = nil,
         communityContext: GetCommunityResponse? = nil) {
        self.user = user
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        
        _postContext = State(initialValue: postContext)
        _commentContext = State(initialValue: commentContext)
        _communityContext = State(initialValue: communityContext)
    }
    
    var showAvatar: Bool {
        if let overrideShowAvatar = overrideShowAvatar {
            return overrideShowAvatar
        } else {
            return shouldShowUserAvatars
        }
    }
    
    static let developerNames = [
        "lemmy.tespia.org/u/navi",
        "beehaw.org/u/jojo",
        "beehaw.org/u/kronusdark",
        "vlemmy.net/u/ericbandrews",
        "programming.dev/u/tht7"
    ]
    
    static let mlemOfficial = "vlemmy.net/u/MlemOfficial"
    
    static let flairMlemOfficial = UserProfileLinkFlair(color: Color.purple, image: Image("mlem"))
    static let flairDeveloper = UserProfileLinkFlair(color: Color.purple, image: Image(systemName: "hammer.fill"))
    static let flairMod = UserProfileLinkFlair(color: Color.green, image: Image(systemName: "shield.fill"))
    static let flairBot = UserProfileLinkFlair(color: Color.indigo, image: Image(systemName: "server.rack"))
    static let flairOP = UserProfileLinkFlair(color: Color.orange, image: Image(systemName: "person.fill"))
    static let flairAdmin = UserProfileLinkFlair(color: Color.red, image: Image(systemName: "crown.fill"))
    static let flairRegular = UserProfileLinkFlair(color: Color.gray)
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if showAvatar {
                userAvatar
            }
            userName
        }
    }
    
    @ViewBuilder
    private var userAvatar: some View {
        Group {
            if let userAvatarLink = user.avatar {
                CachedAsyncImage(url: avatarUrl(from: userAvatarLink), urlCache: AppConstants.urlCache) { image in
                    if let avatar = image.image {
                        avatar
                            .resizable()
                            .scaledToFill()
                            .frame(width: avatarSize(), height: avatarSize())
                    } else {
                        defaultUserAvatar()
                    }
                }
            } else {
                defaultUserAvatar()
            }
        }
        .frame(width: avatarSize(), height: avatarSize())
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
        .accessibilityHidden(true)
    }
    
    private func avatarSize() -> CGFloat {
        serverInstanceLocation == .bottom ? AppConstants.largeAvatarSize : AppConstants.smallAvatarSize
    }
    
    private func avatarUrl(from: URL) -> URL {
        serverInstanceLocation == .bottom ? from.withIcon64Parameters : from.withIcon32Parameters
    }
    
    private func defaultUserAvatar() -> some View {
        Image(systemName: "person.circle")
            .resizable()
            .scaledToFill()
            .frame(width: avatarSize(), height: avatarSize())
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var userName: some View {
        let flair = calculateLinkFlair()
        
        HStack(spacing: 4) {
            if let flairImage = flair.image, serverInstanceLocation != .trailing {
                flairImage
                    .foregroundColor(flair.color)
            }
            
            switch serverInstanceLocation {
            case .disabled:
                userName(with: flair)
            case .bottom:
                VStack(alignment: .leading) {
                    userName(with: flair)
                    userInstance
                }
            case .trailing:
                HStack(spacing: 0) {
                    userName(with: flair)
                    userInstance
                }
            }
        }
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private func userName(with flair: UserProfileLinkFlair) -> some View {
        Text(user.displayName ?? user.name)
            .bold()
            .font(.footnote)
            .foregroundColor(flair.color)
    }
    
    @ViewBuilder
    private var userInstance: some View {
        if let host = user.actorId.host() {
            Text("@\(host)")
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .opacity(0.6)
                .font(.caption)
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
    
    struct UserProfileLinkFlair {
        var color: Color
        var image: Image?
    }
    
    private func calculateLinkFlair() -> UserProfileLinkFlair {
        if let userServer = user.actorId.host() {
            /*
            if UserProfileLabel.mlemOfficial == "\(userServer)\(user.actorId.path())" {
                return UserProfileLabel.flairMlemOfficial
            }
            */
            
            if UserProfileLabel.developerNames.contains(where: { $0 == "\(userServer)\(user.actorId.path())" }) {
                return UserProfileLabel.flairDeveloper
            }
        }
        if user.admin {
            return UserProfileLabel.flairAdmin
        }
        if user.botAccount {
            return UserProfileLabel.flairBot
        }
        if let comment = commentContext, comment.distinguished {
            return UserProfileLabel.flairMod
        }
        if let community = communityContext, community.moderators.contains(where: { $0.moderator == user }) {
            return UserProfileLabel.flairMod
        }
        if let post = postContext, post.creatorId == user.id {
            return UserProfileLabel.flairOP
        }
        return UserProfileLabel.flairRegular
    }
}

// TODO: darknavi - Move these to a common area for reuse
struct UserProfileLinkPreview: PreviewProvider {
    static let previewAccount = SavedAccount(
        id: 0,
        instanceLink: URL(string: "lemmy.com")!,
        accessToken: "abcdefg",
        username: "Test Account"
    )
    
    // Only Admin and Bot work right now
    // Because the rest require post/comment context
    enum PreviewUserType: String, CaseIterable {
        case normal = "normal"
        case mod = "mod"
        case op = "op"
        case bot = "bot"
        case admin = "admin"
        case dev = "developer"
    }
    
    static func generatePreviewUser(name: String, displayName: String, userType: PreviewUserType) -> APIPerson {
        let actorId: URL
        if userType == .dev {
            actorId = URL(string: "http://\(UserProfileLabel.developerNames[0])")!
        } else {
            actorId = URL(string: "http://lemmy.ml/u/ericbandrews")!
        }
        
        return APIPerson(
            id: name.hashValue,
            name: name,
            displayName: displayName,
            avatar: nil,
            banned: false,
            published: Date.now.advanced(by: -120000),
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
    
    static func generateFakeCommunity(id: Int, namePrefix: String) -> APICommunity {
        APICommunity(
            id: id,
            name: "\(namePrefix) Fake Community \(id)",
            title: "\(namePrefix) Fake Community \(id) Title",
            description: "This is a fake community (#\(id))",
            published: Date.now,
            updated: nil,
            removed: false,
            deleted: false,
            nsfw: false,
            actorId: URL(string: "https://lemmy.google.com/c/\(id)")!,
            local: false,
            icon: nil,
            banner: nil,
            hidden: false,
            postingRestrictedToMods: false,
            instanceId: 0
        )
    }
    
    static func generatePreviewPost(creator: APIPerson) -> APIPostView {
        let community = generateFakeCommunity(id: 123, namePrefix: "Test")
        let post = APIPost(
            id: 123,
            name: "Test Post Title",
            url: nil,
            body: "This is a test post body",
            creatorId: creator.id,
            communityId: 123,
            deleted: false,
            embedDescription: "Embeedded Description",
            embedTitle: "Embedded Title",
            embedVideoUrl: nil,
            featuredCommunity: false,
            featuredLocal: false,
            languageId: 0,
            apId: "my.app.id",
            local: false,
            locked: false,
            nsfw: false,
            published: Date.now,
            removed: false,
            thumbnailUrl: nil,
            updated: nil
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
        
        return APIPostView(
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
        )
    }
    
    static func generateUserProfileLink(
        name: String,
        userType: PreviewUserType,
        serverInstanceLocation: ServerInstanceLocation
    ) -> UserProfileLink {
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
        
        return UserProfileLink(
            user: previewUser,
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
                    generateUserProfileLink(name: "\(userType)User", userType: userType, serverInstanceLocation: serverInstanceLocation)
                }
            }
        }
    }
}
