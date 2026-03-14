//
//  InstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 08/07/2024.
//

import ComponentViews
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

struct InstanceView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case about, communities, administration, details, safety
        
        var label: LocalizedStringResource {
            switch self {
            case .about: "About"
            case .communities: "Communities"
            case .administration: "Administration"
            case .details: "Details"
            case .safety: "Trust & Safety"
            }
        }
        
        var id: Self { self }
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.colorScheme) var colorScheme
    
    let visitContext: VisitHistory.VisitContext?

    // This is fetched from the instance itself, not from the logged-in account.
    @State var instance: any InstanceStubProviding
    @State var fediseerData: FediseerData?
    @State var upgradeState: LoadingState = .idle
    @State var communityLoader: CommunityFeedLoader
    
    @State var selectedTab: Tab = .about
    
    @State var showingConfirmation: Bool = false
    @State var newAdmin: Person?

    @State var errorDetails: ErrorDetails?
    @State var communityListErrorDetails: ErrorDetails?
    
    init(instance: any InstanceStubProviding, visitContext: VisitHistory.VisitContext?) {
        self._instance = .init(wrappedValue: instance)
        self._communityLoader = .init(wrappedValue: .init(
            api: .getApiClient(url: instance.actorId.hostUrl, username: nil),
            hostApi: instance.api
        ))
        self.visitContext = visitContext
    }
    
    var body: some View {
        VStack {
            if let errorDetails {
                ErrorView(errorDetails)
            } else if let instance = instance as? any DeprecatedInstance {
                content(instance)
                    .conditionalNavigationTitle(instance.displayName)
            } else {
                ProgressView()
                    .tint(.themedSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: instance is any DeprecatedInstance)
        .animation(.easeOut(duration: 0.2), value: instance.apiIsLocal)
        .task { await refresh() }
        .navigationBarTitleDisplayMode(.inline)
        .themedGroupedBackground()
    }
    
    @ViewBuilder
    func content(_ instance: any DeprecatedInstance) -> some View {
        FancyScrollView {
            ProfileHeaderView(
                instance,
                fallback: .instanceAvatar,
                blockedOverride: (appState.firstSession as? UserSession)?.blocks?.contains(instance)
            )
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            if instance.apiIsLocal {
                BubblePicker(
                    availableTabs,
                    selected: $selectedTab,
                    label: { $0.label }
                )
                switch selectedTab {
                case .about:
                    aboutTab(instance: instance)
                case .communities:
                    InstanceCommunityListView(
                        communityLoader: communityLoader,
                        errorDetails: $communityListErrorDetails
                    )
                case .details:
                    InstanceDetailsView(instance: instance)
                case .administration:
                    administrationTab(instance: instance)
                case .safety:
                    safetyTab(instance: instance)
                        .onAppear(perform: attemptToLoadFediseerData)
                }
            } else {
                ProgressView()
                    .tint(.themedSecondary)
                    .padding(.top)
            }
        }
        .toolbar {
            ToolbarEllipsisMenu(instance: instance)
        }
    }
    
    @ViewBuilder
    func administrationTab(instance: any DeprecatedInstance) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if instance.api.supports(.modlog, defaultValue: true) {
                ModlogButtonView(instance: instance)
            }
            
            VStack(spacing: Constants.main.halfSpacing) {
                ForEach(instance.administrators_ ?? []) { person in
                    PersonListRow(person)
                        .quickSwipes(administratorQuickSwipes(person: person))
                }
            }
            
            if appState.firstApi.isAdmin {
                Button("Add Administrator", icon: .general.add, action: openAddAdminSheet)
                    .buttonStyle(.capsule)
                    .padding(.bottom, Constants.main.halfSpacing)
                    .confirmationDialog("Add Administrator", isPresented: $showingConfirmation) {
                        Button("Yes", action: addNewAdmin)
                    } message: {
                        if let displayName = newAdmin?.displayName {
                            Text("Really appoint \(displayName) as an administrator of \(instance.displayName)?")
                        } else {
                            Text("Really appoint this user as an administrator of \(instance.displayName)?")
                        }
                    }
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func safetyTab(instance: any DeprecatedInstance) -> some View {
        if let fediseerData {
            InstanceSafetyView(instance: instance, fediseerData: fediseerData)
        } else {
            ProgressView()
                .padding(.top, 30)
        }
    }
}
