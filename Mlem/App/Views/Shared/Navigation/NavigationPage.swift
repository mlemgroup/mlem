//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import Actions
import MlemBackend
import MlemMiddleware
import SwiftUI

enum NavigationPage {
    case settings(_ page: SettingsPage = .root)
    case logIn(_ page: LoginPage = .pickInstance)
    case signUp(_ instance: Instance)
    case onboarding
    case feeds(_ selection: ListingType? = nil)
    case savedFeed
    case upvotedFeed
    case topCommunities, topPeople, topInstances
    case profile, inbox, search
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
    case instance(_ instance: Instance, visitContext: VisitHistory.VisitContext = .other)
    case instanceStub(_ instanceStub: InstanceStub, targetPage: (Instance) -> NavigationPage)
    case instanceOpinionList(instance: Instance, opinionType: FediseerOpinionType, data: FediseerData)
    case messageFeed(
        _ person: Person,
        messageContent: String = "",
        focusTextField: Bool = false,
        editing: (any Message1Providing)? = nil
    )
    case fediseerInfo
    case instanceUptime(_ instance: Instance, uptimeData: UptimeData)
    case externalApiInfo(api: ApiClient, actorId: ActorIdentifier)
    case imageViewer(_ url: URL)
    case communityPicker(
        api: ApiClient? = nil,
        callback: (Community, NavigationLayer) -> Void
    )
    case personPicker(
        api: ApiClient? = nil,
        filter: ListingType = .all,
        callback: (Person, NavigationLayer) -> Void
    )
    case instancePicker(
        callback: (InstanceSummary, NavigationLayer) -> Void,
        requiredFeature: Feature? = nil
    )
    case languagePicker(selectedLanguages: Set<Locale.Language>, callback: (Locale.Language) -> Void)
    case selectText(_ string: String)
    case shareInstancePicker(_ sharable: any Sharable & ContentModel)
    case subscriptionList
    case createComment(_ context: CommentEditorView.Context, commentTreeTracker: CommentTreeTracker? = nil)
    case editComment(_ comment: Comment, context: CommentEditorView.Context?)
    case editCommunity(_ community: Community)
    case editNote(_ person: Person)
    case report(_ interactable: any ReportableProviding, community: Community? = nil)
    case remove(_ removable: any RemovableProviding)
    case purge(_ purgable: any PurgableProviding)
    case ban(_ person: Person, isBannedFromCommunity: Bool, shouldBan: Bool, community: Community?)
    case createPost(
        community: Community? = nil,
        title: String = "",
        content: String? = nil,
        type: PostType? = nil,
        nsfw: Bool = false,
        feedLoader: (any FeedLoading)? = nil
    )
    case editPost(_ post: Post)
    case deleteAccount(_ account: UserAccount)
    case bypassImageProxy(callback: () -> Void)
    case confirmUpload(imageData: Data, fileExtension: String, imageManager: ImageUploadManager, uploadApi: ApiClient)
    case rulesList(_ model: any ProfileProviding, callback: (String) -> Void)
    case blockList
    case advancedSorting(_ sort: Binding<PostSortType>)
    case votesList(_ target: VotesListView.Target)
    case modlog(ModlogView.InitialTarget, targetPerson: Person?, moderatorPerson: Person?)
    case denyApplication(RegistrationApplication)
    case exportPostImage(_ post: Post)
    case exportCommentImage(_ comment: Comment, tracker: CommentTreeTracker?)
    case unavailableContentInfo
    case unsupportedVersion(_ account: any Account)
    case postDetails(_ post: Post)
    case authHandoff(session: String, personHandle: PersonHandle, defaultAccount: UserAccount)

    // If `configuration` is specified, show a "customise" button in the sheet for editing that configuration.
    // Otherwise, no "customise" button is shown.
    case actionSheet(
        _ actions: [ActionSheetSection],
        environment: EnvironmentValues,
        configuration: ContextMenuSettingsPage?
    )

    static func modlog(
        community: Community,
        targetPerson: Person? = nil,
        moderatorPerson: Person? = nil
    ) -> NavigationPage {
        modlog(.community(community), targetPerson: targetPerson, moderatorPerson: moderatorPerson)
    }
    
    static func modlog(
        instance: Instance,
        targetPerson: Person? = nil,
        moderatorPerson: Person? = nil
    ) -> NavigationPage {
        modlog(.instance(instance), targetPerson: targetPerson, moderatorPerson: moderatorPerson)
    }

    static func modlog(
        targetPerson: Person? = nil,
        moderatorPerson: Person? = nil
    ) -> NavigationPage {
        modlog(.currentInstance, targetPerson: targetPerson, moderatorPerson: moderatorPerson)
    }
    
    static func instanceStub(_ stub: InstanceStub, visitContext: VisitHistory.VisitContext = .other) -> NavigationPage {
        .instanceStub(stub, targetPage: { .instance($0, visitContext: visitContext) })
    }

    static func hostInstance(
        of entity: any ActorIdentifiable,
        visitContext: VisitHistory.VisitContext = .other
    ) -> NavigationPage {
        if let entity = entity as? Person,
           let instance = entity.instance.value_ {
            return .instance(instance, visitContext: visitContext)
        }
        if let entity = entity as? Community,
           let instance = entity.instance.value_ as? Instance {
            return .instance(instance, visitContext: visitContext)
        }
        return .instanceStub(.init(api: AppState.main.firstApi, actorId: .instance(host: entity.actorId.host)))
    }
    
    static func signUp() -> NavigationPage {
        .instancePicker(callback: { instance, navigation in
            Task { @MainActor in
                navigation.push(.signUp(instance.instanceStub))
            }
        }, requiredFeature: .signUp)
    }
    
    static func signUp(_ stub: InstanceStub) -> NavigationPage {
        .instanceStub(stub, targetPage: { .signUp($0) })
    }
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: { value, navigation in
            Task { @MainActor in
                navigation.dismissSheet()
                callback(value)
            }
        })
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        filter: ListingType = .all,
        callback: @escaping (Person) -> Void
    ) -> NavigationPage {
        personPicker(api: api, filter: filter, callback: { value, navigation in
            Task { @MainActor in
                navigation.dismissSheet()
                callback(value)
            }
        })
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary) -> Void,
        requiredFeature: Feature? = nil
    ) -> NavigationPage {
        instancePicker(
            callback: { value, navigation in
                Task { @MainActor in
                    navigation.dismissSheet()
                    callback(value)
                }
            },
            requiredFeature: requiredFeature
        )
    }
    
    static func actionSheet(
        _ actions: [ActionSheetSection],
        environment: EnvironmentValues,
        configuration: ReferenceWritableKeyPath<SettingsValues, some ContextMenuConfiguration>? = nil
    ) -> NavigationPage {
        actionSheet(
            actions,
            environment: environment,
            configuration: configuration.map(ContextMenuSettingsPage.init)
        )
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .report, .externalApiInfo, .selectText, .createComment,
             .editComment, .createPost, .editPost, .denyApplication, .actionSheet, .authHandoff:
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
