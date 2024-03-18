//
//  ModlogView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-10.
//

import Dependencies
import Foundation
import SwiftUI

// swiftlint:disable file_length

// swiftlint:disable:next type_body_length
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
    
    @State var instanceContext: InstanceModel?
    @State var communityContext: CommunityModel?
    
    @State var errorDetails: ErrorDetails?
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    // sorry swiftlint but the API made me do it
    // swiftlint:disable:next function_body_length
    init(modlogLink: ModlogLink) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        
        switch modlogLink {
        case .userInstance:
            self._instanceContext = .init(wrappedValue: nil)
            self._communityContext = .init(wrappedValue: nil)
        case let .instance(instanceModel):
            self._instanceContext = .init(wrappedValue: instanceModel)
            self._communityContext = .init(wrappedValue: nil)
        case let .community(communityModel):
            self._instanceContext = .init(wrappedValue: nil) // TODO: home instance
            self._communityContext = .init(wrappedValue: communityModel)
        }
          
        let postRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .postRemoval,
            modlogLink: modlogLink
        )
        
        let postLocksTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .postLock,
            modlogLink: modlogLink
        )
        
        let postPinsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .postPin,
            modlogLink: modlogLink
        )
        
        let commentRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .commentRemoval,
            modlogLink: modlogLink
        )
        
        let communityRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .communityRemoval,
            modlogLink: modlogLink
        )
        
        let communityBansTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .communityBan,
            modlogLink: modlogLink
        )
        
        let instanceBansTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .instanceBan,
            modlogLink: modlogLink
        )
        
        let moderatorAddsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .moderatorAdd,
            modlogLink: modlogLink
        )
        
        let communityTransfersTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .communityTransfer,
            modlogLink: modlogLink
        )
        
        let administratorAddsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .administratorAdd,
            modlogLink: modlogLink
        )
        
        let personPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .personPurge,
            modlogLink: modlogLink
        )
        
        let communityPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .communityPurge,
            modlogLink: modlogLink
        )
        
        let postPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .postPurge,
            modlogLink: modlogLink
        )
        
        let commentPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .commentPurge,
            modlogLink: modlogLink
        )
        
        let communityHidesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .published,
            actionType: .communityHide,
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
            ]
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
        ScrollViewReader { scrollProxy in
            content
                .animation(.easeOut(duration: 0.2), value: currentTracker.items.isEmpty)
                .task { await currentTracker.loadMoreItems() }
                .refreshable {
                    await Task {
                        await modlogTracker.refresh()
                    }.value
                }
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
                    case .commentRemoval:
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
                    
                    if currentTracker.items.isEmpty {
                        Task {
                            await currentTracker.loadMoreItems()
                        }
                    }
                }
                .navigationTitle("Modlog")
                .hoistNavigation {
                    if scrollToTopAppeared {
                        return false
                    }
                    withAnimation {
                        scrollProxy.scrollTo(scrollToTop, anchor: .bottom)
                    }
                    return true
                }
                .fancyTabScrollCompatible()
        }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                
                Divider()
  
                header
                    .padding(AppConstants.standardSpacing)
//                VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
//                    if let instanceContext {
//                        InstanceLabelView(instance: instanceContext)
//                    }
//
//                    if let communityContext {
//                        CommunityLabelView(community: communityContext, serverInstanceLocation: .bottom)
//                    }
//
//                    header
//                }
//                .padding(AppConstants.standardSpacing)
                
                Divider()
                
                if currentTracker.items.isEmpty {
                    noEntriesView()
                } else {
                    ForEach(currentTracker.items, id: \.uid) { entry in
                        entryView(for: entry)
                    }
                    
                    EndOfFeedView(loadingState: currentTracker.loadingState, viewType: .turtle)
                }
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack {
            // Text("Action Type")
            if let instanceContext {
                InstanceLabelView(instance: instanceContext)
            }
            
            if let communityContext {
                CommunityLabelView(community: communityContext, serverInstanceLocation: .bottom)
            }
            
            Spacer()
            
            Picker("Modlog Action", selection: $selectedAction) {
                ForEach(ModlogAction.allCases, id: \.self) { action in
                    Text(action.label)
                }
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
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.1), value: currentTracker.loadingState)
    }
}

// swiftlint:enable file_length
