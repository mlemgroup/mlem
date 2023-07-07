//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI
import AlertToast

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @Environment(\.scenePhase) var phase

    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @State var navigationPath = NavigationPath()

    @State var isShowingInstanceAdditionSheet: Bool = false

    @State var rootDetails: CommunityLinkWithContext?

    var body: some View {

        NavigationSplitView {
            AccountsPage(isShowingInstanceAdditionSheet: $isShowingInstanceAdditionSheet)
        } content: {
            if appState.currentActiveAccount != nil {
                CommunityListView(
                    account: appState.currentActiveAccount!,
                    selectedCommunity: $rootDetails
                ).id(appState.currentActiveAccount!.id)
            } else {
                Text("You need to be signed in to browse Lemmy")
                Button {
                    isShowingInstanceAdditionSheet.toggle()
                } label: {
                    Label("Sign in", systemImage: "person.badge.plus")
                }
            }
        } detail: {
            if rootDetails != nil {
                NavigationStack(path: $navigationPath) {
                    CommunityView(account: appState.currentActiveAccount!,
                                  community: rootDetails!.community,
                                  feedType: rootDetails!.feedType
                    )
                    .environmentObject(appState)
                    .handleLemmyViews()
                }
                .id(rootDetails!.id + appState.currentActiveAccount!.id)
            } else {
                Text("Please selecte a community")
                    .id(appState.currentActiveAccount?.id ?? 0)
            }
        }
        .handleLemmyLinkResolution(
            navigationPath: $navigationPath
        )
        .environment(\.navigationPath, $navigationPath)
        .environmentObject(appState)
        .environmentObject(accountsTracker)
        .toast(isPresenting: $appState.isShowingToast) {
            appState.toast ?? AlertToast(type: .regular, title: "Missing toast info")
        }
        .alert(appState.alertTitle, isPresented: $appState.isShowingAlert) {
            Button(role: .cancel) {
                appState.isShowingAlert.toggle()
            } label: {
                Text("Close")
            }

        } message: {
            Text(appState.alertMessage)
        }
        .onAppear {
            if rootDetails == nil || shortcutItemToProcess != nil {
                let feedType = FeedType(rawValue:
                    shortcutItemToProcess?.type ??
                    "nothing to see here"
                ) ?? defaultFeed
                var detailsViewToDisplay: CommunityLinkWithContext?
                if appState.currentActiveAccount != nil {
                    detailsViewToDisplay = CommunityLinkWithContext(community: nil, feedType: feedType)
                }
                rootDetails = detailsViewToDisplay
                shortcutItemToProcess = nil
            }
        }
        .onOpenURL { url in
            if appState.currentActiveAccount == nil {
                if let account = accountsTracker.savedAccounts.first {
                    appState.currentActiveAccount = account
                }
            }

            guard appState.currentActiveAccount != nil else {
                appState.toast = AlertToast(
                    displayMode: .hud,
                    type: .loading,
                    title: "You need to sign in to open links in app"
                )

                appState.isShowingToast = true
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if rootDetails == nil {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: defaultFeed)
                }
                
                _ = HandleLemmyLinkResolution(appState: _appState,
                                          navigationPath: $navigationPath
                )
                .didReceiveURL(url)
            }
        }
        .sheet(isPresented: $isShowingInstanceAdditionSheet) {
            AddSavedInstanceView(isShowingSheet: $isShowingInstanceAdditionSheet)
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .active {
                if appState.currentActiveAccount != nil,
                   let shortcutItem = FeedType(rawValue:
                                                shortcutItemToProcess?.type ??
                                               "nothing to see here"
                   ) {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: shortcutItem)

                    shortcutItemToProcess = nil
                }
            }
        }
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot()
    }
}

private func subscribe(account: SavedAccount, communityId: Int, shouldSubscribe: Bool) async -> Bool {
    do {
        let request = FollowCommunityRequest(
            account: account,
            communityId: communityId,
            follow: shouldSubscribe
        )

        _ = try await APIClient().perform(request: request)
        return true
    } catch {
        // TODO: If we fail here and want to notify the user we'd ideally
        // want to do so from the parent view, I think it would be worth refactoring
        // this view so that the responsibility for performing the call is removed
        // and handled by the parent, for now we will fail silently the UI state
        // will not update so will continue to be accurate
        print(error)
        return false
    }
}
