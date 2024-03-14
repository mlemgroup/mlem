//
//  ModlogView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-10.
//

import Dependencies
import Foundation
import SwiftUI

enum ModlogAction: CaseIterable {
    case all, postRemoval, postLock, postPin, commentremoval, communityRemoval, communityBan, instanceBan,
         moderatorAdd, communityTransfer, administratorAdd, personPurge, communityPurge, postPurge, commentPurge, communityHide
    
    var label: String {
        switch self {
        case .all:
            "All"
        case .postRemoval:
            "Removed Post"
        case .postLock:
            "Locked Post"
        case .postPin:
            "Pinned Post"
        case .commentremoval:
            "Removed Comment"
        case .communityRemoval:
            "Removed Community"
        case .communityBan:
            "Banned from Community"
        case .instanceBan:
            "Banned from Instance"
        case .moderatorAdd:
            "Appointed Moderator"
        case .communityTransfer:
            "Transferred Community"
        case .administratorAdd:
            "Appointed Administrator"
        case .personPurge:
            "Purged Person"
        case .communityPurge:
            "Purged Community"
        case .postPurge:
            "Purged Post"
        case .commentPurge:
            "Purged Comment"
        case .communityHide:
            "Hid Community"
        }
    }
}

struct ModlogView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    // TODO: 2.0 enable searching--search needs to be submitted against the instance that the modlog is fetched from to ensure that the communityId/moderatorId is locally correct, which is annoying right now but very easy in 2.0.
    
    @State var selectedAction: ModlogAction = .all
    
    @State var currentTracker: any ModlogTrackerProtocol
    @StateObject var modlogTracker: ModlogTracker
    @StateObject var postRemovalsTracker: ModlogChildTracker
    @StateObject var postLocksTracker: ModlogChildTracker
    @StateObject var postPinsTracker: ModlogChildTracker
    @StateObject var commentRemovalsTracker: ModlogChildTracker
    @StateObject var communityRemovalsTracker: ModlogChildTracker
    @StateObject var communityBansTracker: ModlogChildTracker
    @StateObject var instanceBansTracker: ModlogChildTracker
    @StateObject var moderatorAddsTracker: ModlogChildTracker
    @StateObject var communityTransfersTracker: ModlogChildTracker
    @StateObject var administratorAddsTracker: ModlogChildTracker
    @StateObject var personPurgesTracker: ModlogChildTracker
    @StateObject var communityPurgesTracker: ModlogChildTracker
    @StateObject var postPurgesTracker: ModlogChildTracker
    @StateObject var commentPurgesTracker: ModlogChildTracker
    @StateObject var communityHidesTracker: ModlogChildTracker
    
    @State var errorDetails: ErrorDetails?
    
    // sorry swiftlint but the API made me do it
    // swiftlint:disable:next function_body_length
    init(modlogLink: ModlogLink) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        
        let postRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modRemovePost,
            modlogLink: modlogLink
        )
        
        let postLocksTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modLockPost,
            modlogLink: modlogLink
        )
        
        let postPinsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modFeaturePost,
            modlogLink: modlogLink
        )
        
        let commentRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modRemoveComment,
            modlogLink: modlogLink
        )
        
        let communityRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modRemoveCommunity,
            modlogLink: modlogLink
        )
        
        let communityBansTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modBanFromCommunity,
            modlogLink: modlogLink
        )
        
        let instanceBansTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modBan,
            modlogLink: modlogLink
        )
        
        let moderatorAddsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modAddCommunity,
            modlogLink: modlogLink
        )
        
        let communityTransfersTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modTransferCommunity,
            modlogLink: modlogLink
        )
        
        let administratorAddsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modAdd,
            modlogLink: modlogLink
        )
        
        let personPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .adminPurgePerson,
            modlogLink: modlogLink
        )
        
        let communityPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .adminPurgeCommunity,
            modlogLink: modlogLink
        )
        
        let postPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .adminPurgePost,
            modlogLink: modlogLink
        )
        
        let commentPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .adminPurgeComment,
            modlogLink: modlogLink
        )
        
        let communityHidesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .modHideCommunity,
            modlogLink: modlogLink
        )
        
        let modlogTracker: ModlogTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            childTrackers: [
                postRemovalsTracker,
                postLocksTracker,
                postPinsTracker,
                commentRemovalsTracker,
                communityRemovalsTracker,
                communityBansTracker,
                instanceBansTracker,
                moderatorAddsTracker,
                communityTransfersTracker,
                administratorAddsTracker,
                personPurgesTracker,
                communityPurgesTracker,
                postPurgesTracker,
                commentPurgesTracker,
                communityHidesTracker
            ],
            preheatChildren: true
        )
        
        self._postRemovalsTracker = .init(wrappedValue: postRemovalsTracker)
        self._postLocksTracker = .init(wrappedValue: postLocksTracker)
        self._postPinsTracker = .init(wrappedValue: postPinsTracker)
        self._commentRemovalsTracker = .init(wrappedValue: commentRemovalsTracker)
        self._communityRemovalsTracker = .init(wrappedValue: communityRemovalsTracker)
        self._communityBansTracker = .init(wrappedValue: communityBansTracker)
        self._instanceBansTracker = .init(wrappedValue: instanceBansTracker)
        self._moderatorAddsTracker = .init(wrappedValue: moderatorAddsTracker)
        self._communityTransfersTracker = .init(wrappedValue: communityTransfersTracker)
        self._administratorAddsTracker = .init(wrappedValue: administratorAddsTracker)
        self._personPurgesTracker = .init(wrappedValue: personPurgesTracker)
        self._communityPurgesTracker = .init(wrappedValue: communityPurgesTracker)
        self._postPurgesTracker = .init(wrappedValue: postPurgesTracker)
        self._commentPurgesTracker = .init(wrappedValue: commentPurgesTracker)
        self._communityHidesTracker = .init(wrappedValue: communityHidesTracker)
        self._modlogTracker = .init(wrappedValue: modlogTracker)
        self._currentTracker = .init(wrappedValue: modlogTracker)
    }

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: currentTracker.items.isEmpty)
            .task { await currentTracker.loadMoreItems() }
            .onChange(of: selectedAction) { newValue in
                switch newValue {
                case .all:
                    currentTracker = modlogTracker
                case .postRemoval:
                    currentTracker = postRemovalsTracker
                case .postLock:
                    currentTracker = postLocksTracker
                case .postPin:
                    currentTracker = postPinsTracker
                case .commentremoval:
                    currentTracker = commentRemovalsTracker
                case .communityRemoval:
                    currentTracker = communityRemovalsTracker
                case .communityBan:
                    currentTracker = communityBansTracker
                case .instanceBan:
                    currentTracker = instanceBansTracker
                case .moderatorAdd:
                    currentTracker = moderatorAddsTracker
                case .communityTransfer:
                    currentTracker = communityTransfersTracker
                case .administratorAdd:
                    currentTracker = administratorAddsTracker
                case .personPurge:
                    currentTracker = personPurgesTracker
                case .communityPurge:
                    currentTracker = communityPurgesTracker
                case .postPurge:
                    currentTracker = postPurgesTracker
                case .commentPurge:
                    currentTracker = commentPurgesTracker
                case .communityHide:
                    currentTracker = communityHidesTracker
                }
            }
            .navigationTitle("Modlog")
            .hoistNavigation()
            .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                actionPicker
               
                if currentTracker.items.isEmpty {
                    noEntriesView()
                } else {
                    Divider()
                    
                    ForEach(currentTracker.items, id: \.uid) { entry in
                        entryView(for: entry)
                    }
                    
                    EndOfFeedView(loadingState: currentTracker.loadingState, viewType: .turtle)
                }
            }
        }
    }
    
    @ViewBuilder
    var actionPicker: some View {
        Picker("Modlog Action", selection: $selectedAction) {
            ForEach(ModlogAction.allCases, id: \.self) { action in
                Text(action.label)
            }
        }
    }
    
    @ViewBuilder
    private func entryView(for entry: ModlogEntry) -> some View {
        VStack(spacing: 0) {
            ModlogEntryView(modlogEntry: entry)
            Divider()
        }
        .onAppear { currentTracker.loadIfThreshold(entry) }
    }
    
    @ViewBuilder
    private func noEntriesView() -> some View {
        VStack {
            if currentTracker.loadingState == .loading ||
                (currentTracker.items.isEmpty && currentTracker.loadingState == .idle) {
                LoadingView(whatIsLoading: .modlog)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else if currentTracker.loadingState == .done {
                Text("No items found")
                    .padding(.top, 20)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.1), value: currentTracker.loadingState)
    }
}
