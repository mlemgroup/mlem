//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import MlemMiddleware
import SwiftUI

// swiftlint:disable:next type_body_length
enum NavigationPage: Hashable {
    case settings(_ page: SettingsPage = .root)
    case logIn(_ page: LoginPage = .pickInstance)
    case signUp(_ instance: HashWrapper<any InstanceStubProviding>)
    case feeds(_ selection: FeedSelection? = nil)
    case profile, inbox, search
    case quickSwitcher
    case post(
        _ post: AnyPost,
        scrollTargetedComment: HashWrapper<any CommentStubProviding>? = nil,
        communityContext: HashWrapper<any Community1Providing>? = nil,
        navigationNamespace: Namespace.ID? = nil
    )
    case comment(_ comment: AnyComment, comments: [Comment2]?, showViewPostButton: Bool)
    case community(_ community: AnyCommunity)
    case person(_ person: AnyPerson)
    case instance(_ instance: InstanceHashWrapper)
    case instanceOpinionList(instance: InstanceHashWrapper, opinionType: FediseerOpinionType, data: FediseerData)
    case messageFeed(_ person: AnyPerson, focusTextField: Bool, editing: MessageHashWrapper?)
    case fediseerInfo
    case externalApiInfo(api: ApiClient, actorId: URL)
    case imageViewer(_ url: URL)
    case communityPicker(api: ApiClient?, callback: HashWrapper<(Community2, NavigationLayer) -> Void>)
    case personPicker(api: ApiClient?, callback: HashWrapper<(Person2, NavigationLayer) -> Void>)
    case instancePicker(callback: HashWrapper<(InstanceSummary, NavigationLayer) -> Void>, minimumVersion: SiteVersion? = nil)
    case selectText(_ string: String)
    case subscriptionList
    case createComment(_ context: CommentEditorView.Context, commentTreeTracker: CommentTreeTracker? = nil)
    case editComment(_ comment: Comment2, context: CommentEditorView.Context?)
    case report(_ interactable: ReportableHashWrapper, community: AnyCommunity? = nil)
    case remove(_ removable: RemovableHashWrapper)
    case purge(_ purgable: PurgableHashWrapper)
    case ban(_ person: AnyPerson, isBannedFromCommunity: Bool, shouldBan: Bool, community: AnyCommunity?)
    case createPost(
        community: AnyCommunity?,
        title: String,
        content: String,
        url: URL?,
        nsfw: Bool
    )
    case editPost(_ post: Post2)
    case deleteAccount(_ account: UserAccount)
    case bypassImageProxy(callback: HashWrapper<() -> Void>)
    case confirmUpload(imageData: Data, imageManager: ImageUploadManager, uploadApi: ApiClient)
    case rulesList(_ model: Profile2HashWrapper, callback: HashWrapper<(String) -> Void>)
    case blockList
    case advancedSorting(_ sort: HashWrapper<Binding<ApiSortType>>)
    case votesList(_ target: VotesListView.Target)
    
    static func post(_ post: any PostStubProviding, scrollTargetedComment: (any CommentStubProviding)? = nil) -> NavigationPage {
        if let scrollTargetedComment {
            return Self.post(.init(post), scrollTargetedComment: .init(wrappedValue: scrollTargetedComment))
        } else {
            return Self.post(.init(post))
        }
    }
    
    static func post(
        _ post: any PostStubProviding,
        communityContext: (any Community1Providing)?,
        navigationNamespace: Namespace.ID? = nil
    ) -> NavigationPage {
        if let communityContext {
            Self.post(.init(post), communityContext: .init(wrappedValue: communityContext), navigationNamespace: navigationNamespace)
        } else {
            Self.post(.init(post), navigationNamespace: navigationNamespace)
        }
    }
    
    static func comment(
        _ comment: any CommentStubProviding,
        comments: [Comment2]? = nil,
        showViewPostButton: Bool = true
    ) -> NavigationPage {
        Self.comment(.init(comment), comments: comments, showViewPostButton: showViewPostButton)
    }
    
    static func person(_ person: any PersonStubProviding) -> NavigationPage {
        Self.person(.init(person))
    }
    
    static func community(_ community: any CommunityStubProviding) -> NavigationPage {
        Self.community(.init(community))
    }

    static func instance(_ instance: any InstanceStubProviding) -> NavigationPage {
        Self.instance(.init(wrappedValue: instance))
    }
    
    static func instanceOpinionList(
        _ instance: any InstanceStubProviding,
        opinionType: FediseerOpinionType,
        data: FediseerData
    ) -> NavigationPage {
        instanceOpinionList(
            instance: .init(wrappedValue: instance),
            opinionType: opinionType,
            data: data
        )
    }
    
    static func messageFeed(
        _ person: any PersonStubProviding,
        focusTextField: Bool = false,
        editing: (any Message1Providing)? = nil
    ) -> NavigationPage {
        var editingWrapper: MessageHashWrapper?
        if let editing {
            editingWrapper = .init(wrappedValue: editing)
        }
        return messageFeed(.init(person), focusTextField: focusTextField, editing: editingWrapper)
    }
    
    static func instance(hostOf entity: any ActorIdentifiable) -> NavigationPage {
        var instance: any InstanceStubProviding = InstanceStub(
            api: AppState.main.firstApi, actorId: entity.actorId.removingPathComponents()
        )
        if let entity = entity as? any Person3Providing {
            instance = entity.instance ?? instance
        } else if let entity = entity as? any Community3Providing {
            instance = entity.instance ?? instance
        }
        return Self.instance(.init(wrappedValue: instance))
    }
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community2, NavigationLayer) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: .init(wrappedValue: callback))
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        callback: @escaping (Person2, NavigationLayer) -> Void
    ) -> NavigationPage {
        personPicker(api: api, callback: .init(wrappedValue: callback))
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary, NavigationLayer) -> Void,
        minimumVersion: SiteVersion? = nil
    ) -> NavigationPage {
        assert((minimumVersion ?? .infinity) > Constants.main.minimumLemmyVersion)
        return instancePicker(callback: .init(wrappedValue: callback), minimumVersion: minimumVersion)
    }
    
    static func signUp() -> NavigationPage {
        .instancePicker(callback: { instance, navigation in
            if let stub = instance.instanceStub {
                Task { @MainActor in
                    navigation.push(.signUp(stub))
                }
            }
        })
    }
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community2) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: .init(wrappedValue: { value, navigation in
            callback(value)
            Task { @MainActor in
                navigation.dismissSheet()
            }
        }))
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        callback: @escaping (Person2) -> Void
    ) -> NavigationPage {
        personPicker(api: api, callback: .init(wrappedValue: { value, navigation in
            callback(value)
            Task { @MainActor in
                navigation.dismissSheet()
            }
        }))
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary) -> Void,
        minimumVersion: SiteVersion? = nil
    ) -> NavigationPage {
        assert((minimumVersion ?? .infinity) > Constants.main.minimumLemmyVersion)
        return instancePicker(callback: .init(wrappedValue: { value, navigation in
            callback(value)
            Task { @MainActor in
                navigation.dismissSheet()
            }
        }), minimumVersion: minimumVersion)
    }
    
    static func createPost(
        community: (any CommunityStubProviding)?,
        title: String = "",
        content: String = "",
        url: URL? = nil,
        nsfw: Bool = false
    ) -> NavigationPage {
        let anyCommunity: AnyCommunity?
        if let community {
            anyCommunity = .init(community)
        } else {
            anyCommunity = nil
        }
        return createPost(
            community: anyCommunity,
            title: title,
            content: content,
            url: url,
            nsfw: nsfw
        )
    }

    static func report(_ interactable: any ReportableProviding, community: (any CommunityStubProviding)?) -> NavigationPage {
        let anyCommunity: AnyCommunity?
        if let community {
            anyCommunity = .init(community)
        } else {
            anyCommunity = nil
        }
        return report(.init(wrappedValue: interactable), community: anyCommunity)
    }
    
    static func remove(_ interactable: any RemovableProviding) -> NavigationPage {
        remove(.init(wrappedValue: interactable))
    }
    
    static func purge(_ purgable: any PurgableProviding) -> NavigationPage {
        purge(.init(wrappedValue: purgable))
    }
    
    static func ban(
        _ person: any Person,
        isBannedFromCommunity: Bool,
        shouldBan: Bool,
        community: (any Community)? = nil
    ) -> NavigationPage {
        if let community {
            ban(.init(person), isBannedFromCommunity: isBannedFromCommunity, shouldBan: shouldBan, community: .init(community))
        } else {
            ban(.init(person), isBannedFromCommunity: isBannedFromCommunity, shouldBan: shouldBan, community: nil)
        }
    }
    
    static func signUp(_ instance: any InstanceStubProviding) -> NavigationPage {
        signUp(.init(wrappedValue: instance))
    }
    
    static func bypassImageProxyWarning(callback: @escaping () -> Void) -> NavigationPage {
        bypassImageProxy(callback: .init(wrappedValue: callback))
    }
    
    static func rulesList(_ model: any Profile2Providing, callback: @escaping (String) -> Void) -> NavigationPage {
        rulesList(.init(wrappedValue: model), callback: .init(wrappedValue: callback))
    }
    
    static func advancedSorting(_ sort: Binding<ApiSortType>) -> NavigationPage {
        advancedSorting(.init(wrappedValue: sort))
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .report, .externalApiInfo, .selectText, .createComment, .editComment, .createPost, .editPost:
            false
        default:
            true
        }
    }
    
    var canDisplayToasts: Bool {
        switch self {
        case .quickSwitcher, .externalApiInfo, .selectText, .advancedSorting:
            false
        default:
            true
        }
    }
}

struct HashWrapper<Value>: Hashable, Identifiable {
    let wrappedValue: Value
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HashWrapper, rhs: HashWrapper) -> Bool {
        lhs.id == rhs.id
    }
}

struct InstanceHashWrapper: Hashable {
    var wrappedValue: any InstanceStubProviding
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: InstanceHashWrapper, rhs: InstanceHashWrapper) -> Bool {
        lhs.id == rhs.id
    }
}

struct Interactable2HashWrapper: Hashable {
    var wrappedValue: any Interactable2Providing
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: Interactable2HashWrapper, rhs: Interactable2HashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct ReportableHashWrapper: Hashable {
    var wrappedValue: any ReportableProviding
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: ReportableHashWrapper, rhs: ReportableHashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct RemovableHashWrapper: Hashable {
    var wrappedValue: any RemovableProviding
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: RemovableHashWrapper, rhs: RemovableHashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct PurgableHashWrapper: Hashable {
    var wrappedValue: any PurgableProviding
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: PurgableHashWrapper, rhs: PurgableHashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct Profile2HashWrapper: Hashable {
    var wrappedValue: any Profile2Providing
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.actorId)
    }
    
    static func == (lhs: Profile2HashWrapper, rhs: Profile2HashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct MessageHashWrapper: Hashable {
    var wrappedValue: any Message1Providing
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.actorId)
    }
    
    static func == (lhs: MessageHashWrapper, rhs: MessageHashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
