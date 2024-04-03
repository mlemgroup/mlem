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
    @AppStorage("showModlogWarning") var showModlogWarning: Bool = true
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    // TODO: 2.0 enable searching--search needs to be submitted against the instance that the modlog is fetched from to ensure that the communityId/moderatorId is locally correct, which is annoying right now but very easy in 2.0.
    
    @State var selectedAction: ModlogAction = .all
    
    @State var currentTracker: any TrackerProtocol<ModlogEntry>
    
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
    
    @State var modlogWarningDisplayed: Bool
    @State var suppressModlogWarning: Bool = false
    
    @State var errorDetails: ErrorDetails?
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    // TODO: 2.0 tidy this up with @Observable
    // swiftlint:disable:next function_body_length
    init(modlogLink: ModlogLink) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("showModlogWarning") var showModlogWarning = true
        
        self._modlogWarningDisplayed = .init(wrappedValue: showModlogWarning)
        
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
        
        let modlogTracker: ModlogTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            childTrackers: .init()
        )
        
        let postRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .postRemoval,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(postRemovalsTracker)
        
        let postLocksTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .postLock,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(postLocksTracker)
        
        let postPinsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .postPin,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(postPinsTracker)
        
        let commentRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .commentRemoval,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(commentRemovalsTracker)
        
        let communityRemovalsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .communityRemoval,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(communityRemovalsTracker)
        
        let communityBansTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .communityBan,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(communityBansTracker)
        
        let instanceBansTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .instanceBan,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(instanceBansTracker)
        
        let moderatorAddsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .moderatorAdd,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(moderatorAddsTracker)
        
        let communityTransfersTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .communityTransfer,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(communityTransfersTracker)
        
        let administratorAddsTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .administratorAdd,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(administratorAddsTracker)
        
        let personPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .personPurge,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(personPurgesTracker)
        
        let communityPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .communityPurge,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(communityPurgesTracker)
        
        let postPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .postPurge,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(postPurgesTracker)
        
        let commentPurgesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .commentPurge,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(commentPurgesTracker)
        
        let communityHidesTracker: ModlogChildTracker = .init(
            internetSpeed: internetSpeed,
            sortType: .new,
            actionType: .communityHide,
            modlogLink: modlogLink,
            firstPageProvider: modlogTracker
        )
        modlogTracker.addChildTracker(communityHidesTracker)
        
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
        if modlogWarningDisplayed {
            modlogWarning
        } else {
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
    var modlogWarning: some View {
        VStack(alignment: .center, spacing: AppConstants.doubleSpacing) {
            Image(systemName: Icons.warning)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.red)
                .frame(width: 60, height: 60)
            
            Text("The moderation log may contain sensitive or disturbing content. Proceed with caution.")
                .multilineTextAlignment(.center)
                .padding(.bottom, AppConstants.doubleSpacing)
            
            VStack(spacing: AppConstants.standardSpacing) {
                Button {
                    modlogWarningDisplayed = false
                    if suppressModlogWarning {
                        showModlogWarning = false
                    }
                } label: {
                    Text("View Modlog")
                        .padding(3)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Toggle(isOn: $suppressModlogWarning) {
                    Text("Do not show this warning again")
                }
                .padding(5)
            }
        }
        .padding(AppConstants.standardSpacing)
    }
    
    @ViewBuilder
    var header: some View {
        HStack {
            if let instanceContext {
                InstanceLabelView(instance: instanceContext)
            }
            
            if let communityContext {
                CommunityLabelView(community: communityContext, serverInstanceLocation: .bottom)
            }
            
            Spacer()
            
            Picker("Modlog Action", selection: $selectedAction) {
                Text(ModlogAction.all.label).tag(ModlogAction.all)
                
                Divider()
                
                ForEach(ModlogAction.communityActionCases, id: \.self) { action in
                    Text(action.label).tag(action)
                }
                
                Divider()
                
                ForEach(ModlogAction.removalCases, id: \.self) { action in
                    Text(action.label).tag(action)
                }
                
                Divider()
                
                ForEach(ModlogAction.banCases, id: \.self) { action in
                    Text(action.label).tag(action)
                }
                
                Divider()
                
                ForEach(ModlogAction.instanceActionCases, id: \.self) { action in
                    Text(action.label).tag(action)
                }
                
                Divider()
                
                ForEach(ModlogAction.purgeCases, id: \.self) { action in
                    Text(action.label).tag(action)
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
