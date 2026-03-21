//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import Actions
import MlemMiddleware
import SwiftUI

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
enum NavigationPage: Hashable {
    case settings(_ page: SettingsPage = .root)
    case logIn(_ page: LoginPage = .pickInstance)
    case signUp(_ instance: HashWrapper<any InstanceStubProviding>)
    case onboarding
    case feeds(_ selection: ListingType? = nil)
    case savedFeed
    case upvotedFeed
    case topCommunities, topPeople, topInstances
    case profile, inbox, search
    case testInbox
    case quickSwitcher
    case post(
        _ post: Post,
        scrollTargetedComment: Comment? = nil,
        communityContext: Community? = nil,
        navigationNamespace: Namespace.ID? = nil
    )
    case postStub(_ post: PostStub, navigationNamespace: Namespace.ID? = nil)
    case comment(
        _ comment: Comment,
        comments: [Comment]? = nil,
        showViewPostButton: Bool = true,
        exposeRemovedContent: Bool = false
    )
    case commentStub(
        _ comment: CommentStub,
        comments: [Comment]? = nil,
        showViewPostButton: Bool = true,
        exposeRemovedContent: Bool = false
    )
    case communityStub(
        _ community: CommunityStub
    )
    case community(_ community: Community, visitContext: VisitHistory.VisitContext = .other)
    case person(_ person: Person, visitContext: VisitHistory.VisitContext = .other)
    case personStub(_ personStub: PersonStub, visitContext: VisitHistory.VisitContext = .other)
    case instance(_ instance: InstanceHashWrapper, visitContext: VisitHistory.VisitContext)
    case instanceOpinionList(instance: InstanceHashWrapper, opinionType: FediseerOpinionType, data: FediseerData)
    case messageFeed(_ person: Person, messageContent: String, focusTextField: Bool, editing: MessageHashWrapper?)
    case fediseerInfo
    case instanceUptime(_ instance: HashWrapper<any Instance>, _ uptimeData: UptimeData)
    case externalApiInfo(api: ApiClient, actorId: ActorIdentifier)
    case imageViewer(_ url: URL)
    case communityPicker(api: ApiClient?, callback: HashWrapper<(Community, NavigationLayer) -> Void>)
    case personPicker(api: ApiClient?, filter: ListingType, callback: HashWrapper<(Person, NavigationLayer) -> Void>)
    case instancePicker(callback: HashWrapper<(InstanceSummary, NavigationLayer) -> Void>, requiredFeature: Feature? = nil)
    case languagePicker(selectedLanguages: Set<Locale.Language>, callback: HashWrapper<(Locale.Language) -> Void>)
    case selectText(_ string: String)
    case shareInstancePicker(_ sharable: SharableHashWrapper)
    case subscriptionList
    case createComment(_ context: CommentEditorView.Context, commentTreeTracker: CommentTreeTracker? = nil)
    case editComment(_ comment: Comment, context: CommentEditorView.Context?)
    case editCommunity(_ community: Community)
    case editNote(_ person: Person)
    case report(_ interactable: ReportableHashWrapper, community: Community? = nil)
    case remove(_ removable: RemovableHashWrapper)
    case purge(_ purgable: PurgableHashWrapper)
    case ban(_ person: Person, isBannedFromCommunity: Bool, shouldBan: Bool, community: Community?)
    case createPost(
        community: Community?,
        title: String,
        content: String?,
        type: PostType?,
        nsfw: Bool,
        feedLoader: HashWrapper<(any FeedLoading)?>
    )
    case editPost(_ post: Post)
    case deleteAccount(_ account: UserAccount)
    case bypassImageProxy(callback: HashWrapper<() -> Void>)
    case confirmUpload(imageData: Data, fileExtension: String, imageManager: ImageUploadManager, uploadApi: ApiClient)
    case rulesList(_ model: Profile2HashWrapper, callback: HashWrapper<(String) -> Void>)
    case blockList
    case advancedSorting(_ sort: HashWrapper<Binding<PostSortType>>)
    case votesList(_ target: VotesListView.Target)
    case modlog(ModlogView.InitialTarget, targetPerson: Person?, moderatorPerson: Person?)
    case denyApplication(RegistrationApplication)
    case exportPostImage(_ post: Post)
    case exportCommentImage(_ comment: Comment, tracker: CommentTreeTracker?)
    case actionSheet(_ actions: HashWrapper<[ActionSheetSection]>)

    static func instance(
        _ instance: any InstanceStubProviding,
        visitContext: VisitHistory.VisitContext = .other
    ) -> NavigationPage {
        Self.instance(.init(wrappedValue: instance), visitContext: visitContext)
    }
    
    static func shareInstancePicker(_ sharable: any Sharable) -> NavigationPage {
        shareInstancePicker(.init(wrappedValue: sharable))
    }
    
    static func modlog(
        community: Community,
        targetPerson: Person? = nil,
        moderatorPerson: Person? = nil
    ) -> NavigationPage {
        modlog(.community(community), targetPerson: targetPerson, moderatorPerson: moderatorPerson)
    }
    
    static func modlog(
        instance: any Instance,
        targetPerson: Person? = nil,
        moderatorPerson: Person? = nil
    ) -> NavigationPage {
        modlog(.instance(.init(wrappedValue: instance)), targetPerson: targetPerson, moderatorPerson: moderatorPerson)
    }

    static func modlog(
        targetPerson: Person? = nil,
        moderatorPerson: Person? = nil
    ) -> NavigationPage {
        modlog(.currentInstance, targetPerson: targetPerson, moderatorPerson: moderatorPerson)
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
    
    static func instanceUptime(
        instance: any Instance,
        uptimeData: UptimeData
    ) -> NavigationPage {
        .instanceUptime(.init(wrappedValue: instance), uptimeData)
    }
    
    static func messageFeed(
        _ person: Person,
        messageContent: String = "",
        focusTextField: Bool = false,
        editing: (any Message1Providing)? = nil
    ) -> NavigationPage {
        var editingWrapper: MessageHashWrapper?
        if let editing {
            editingWrapper = .init(wrappedValue: editing)
        }
        return messageFeed(
            person,
            messageContent: messageContent,
            focusTextField: focusTextField,
            editing: editingWrapper
        )
    }
    
    static func instance(
        hostOf entity: any ActorIdentifiable,
        visitContext: VisitHistory.VisitContext = .other
    ) -> NavigationPage {
        var instance: any InstanceStubProviding = InstanceStub(
            api: AppState.main.firstApi, actorId: .instance(host: entity.actorId.host)
        )
        if let entity = entity as? Person {
            instance = entity.instance.value_ ?? instance
        } else if let entity = entity as? Community {
            instance = (entity.instance.value_ as? any InstanceStubProviding) ?? instance
        }
        return Self.instance(.init(wrappedValue: instance), visitContext: visitContext)
    }
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community, NavigationLayer) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: .init(wrappedValue: callback))
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        filter: ListingType = .all,
        callback: @escaping (Person, NavigationLayer) -> Void
    ) -> NavigationPage {
        personPicker(api: api, filter: filter, callback: .init(wrappedValue: callback))
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary, NavigationLayer) -> Void,
        requiredFeature: Feature? = nil
    ) -> NavigationPage {
        instancePicker(callback: .init(wrappedValue: callback), requiredFeature: requiredFeature)
    }
    
    static func languagePicker(
        selectedLanguages: Set<Locale.Language>,
        callback: @escaping (Locale.Language) -> Void
    ) -> NavigationPage {
        languagePicker(selectedLanguages: selectedLanguages, callback: .init(wrappedValue: callback))
    }
    
    static func signUp() -> NavigationPage {
        .instancePicker(callback: { instance, navigation in
            Task { @MainActor in
                navigation.push(.signUp(instance.instanceStub))
            }
        }, requiredFeature: .signUp)
    }
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: .init(wrappedValue: { value, navigation in
            Task { @MainActor in
                navigation.dismissSheet()
                callback(value)
            }
        }))
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        filter: ListingType = .all,
        callback: @escaping (Person) -> Void
    ) -> NavigationPage {
        personPicker(api: api, filter: filter, callback: .init(wrappedValue: { value, navigation in
            Task { @MainActor in
                navigation.dismissSheet()
                callback(value)
            }
        }))
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary) -> Void,
        requiredFeature: Feature? = nil
    ) -> NavigationPage {
        instancePicker(callback: .init(wrappedValue: { value, navigation in
            Task { @MainActor in
                navigation.dismissSheet()
                callback(value)
            }
        }), requiredFeature: requiredFeature)
    }
    
    static func createPost(
        community: Community?,
        title: String = "",
        content: String? = nil,
        type: PostType?,
        nsfw: Bool = false,
        feedLoader: (any FeedLoading)?
    ) -> NavigationPage {
        return createPost(
            community: community,
            title: title,
            content: content,
            type: type,
            nsfw: nsfw,
            feedLoader: .init(wrappedValue: feedLoader)
        )
    }

    static func report(_ interactable: any ReportableProviding, community: Community?) -> NavigationPage {
        return report(.init(wrappedValue: interactable), community: community)
    }
    
    static func remove(_ interactable: any RemovableProviding) -> NavigationPage {
        remove(.init(wrappedValue: interactable))
    }
    
    static func purge(_ purgable: any PurgableProviding) -> NavigationPage {
        purge(.init(wrappedValue: purgable))
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
    
    static func advancedSorting(_ sort: Binding<PostSortType>) -> NavigationPage {
        advancedSorting(.init(wrappedValue: sort))
    }

    static func actionSheet(_ actions: [ActionSheetSection]) -> NavigationPage {
        actionSheet(.init(wrappedValue: actions))
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .report, .externalApiInfo, .selectText, .createComment,
             .editComment, .createPost, .editPost, .denyApplication, .actionSheet:
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

struct ReportableHashWrapper: Hashable {
    var wrappedValue: any ReportableProviding
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: ReportableHashWrapper, rhs: ReportableHashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct SharableHashWrapper: Hashable {
    var wrappedValue: any Sharable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: SharableHashWrapper, rhs: SharableHashWrapper) -> Bool {
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

// swiftlint:enable file_length
