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
                    Text("You need to be signed in to brewos Lemmy")
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
            appState: _appState,
            navigationPath: $navigationPath,
            local: "Inside root feed"
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
            if rootDetails == nil {
                var dits: CommunityLinkWithContext?
                if appState.currentActiveAccount != nil {
                    dits = CommunityLinkWithContext(community: nil, feedType: defaultFeed)
                }
                rootDetails = dits
            }
        }
        .onOpenURL { url in
            if appState.currentActiveAccount == nil {
                if let account = accountsTracker.savedAccounts.first {
                    appState.currentActiveAccount = account
                }
            }

            guard let account = appState.currentActiveAccount else {
                appState.toast = AlertToast(displayMode: .hud, type: .loading, title: "You need to sign in to open links in app")
                appState.isShowingToast = true
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if rootDetails == nil {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: defaultFeed)
                }
//                didReceiveURL(url)
                HandleLemmyLinkResolution(appState: _appState,
                                          navigationPath: $navigationPath,
                                          local: "Deep-Link onOpenURL"
                )
                .didReceiveURL(url)
            }
        }
        .sheet(isPresented: $isShowingInstanceAdditionSheet) {
            AddSavedInstanceView(isShowingSheet: $isShowingInstanceAdditionSheet)
        }
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot()
    }
}
