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
    
    // TEMP: tracks whether somebody has seen this alert or not
    @State var showCCAlert: Bool = true
    @State var navPath: NavigationPath = NavigationPath()
    @State var subscribeSwapping: Bool = false
    @State var subscriptionSwapText: String? = "Update my subscriptions"
    // @AppStorage("showCommunityChangeAlert") var showCommunityChangeAlert: Bool = true
    @State var showCommunityChangeAlert: Bool = true // dev - makes it show up every launch

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
                    .handleLemmyLinkResolution(navigationPath: $navigationPath, local: "Inside root details")
                    .handleLemmyViews()
                }.id(rootDetails!.id + appState.currentActiveAccount!.id)
            } else {
                Text("Please selecte a community")
                    .id(appState.currentActiveAccount?.id ?? 0)
            }
        }
        .onChange(of: appState.currentActiveAccount) { newAccount in
            if newAccount != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        let feedType = FeedType(rawValue:
                                                    shortcutItemToProcess?.type ??
                                                "nothing to see here"
                        ) ?? defaultFeed
                        rootDetails = CommunityLinkWithContext(community: nil, feedType: feedType)
                        
                        shortcutItemToProcess = nil
                    }
                }
            }
        }
        .environment(\.navigationPath, $navigationPath)
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
            print("Saved thing from keychain: \(String(describing: AppConstants.keychain["test"]))")
            if appState.currentActiveAccount == nil, let account = accountsTracker.savedAccounts.first {
                appState.currentActiveAccount = account
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if rootDetails == nil {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: defaultFeed)
                }
                _ = HandleLemmyLinkResolution(appState: _appState,
                                          savedAccounts: _accountsTracker,
                                          navigationPath: $navigationPath,
                                          local: "Deep-Link onOpenURL"
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
        .overlay {
            if showCommunityChangeAlert {
                communityChangeAlert()
            }
        }
    }
    
    func communityChangeAlert() -> some View {
        VStack(spacing: 24) {
            Text("We've moved!")
                .font(.title)
                .bold()
                .padding(.bottom, 16)
            
            Text("Our official community has moved from lemmy.ml to vlemmy.net.")
                .padding(.bottom, 16)
            
            if let account = appState.currentActiveAccount {
                Button("Take me there") {
                    Task(priority: .userInitiated) {
                        let resolution = try await APIClient().perform(request: ResolveObjectRequest(account: account,
                                                                                                     query: "https://vlemmy.net/c/mlemapp"))
                        if let community = resolution.community {
                            navigationPath.append(community)
                            showCommunityChangeAlert = false
                        }
                    }
                }
            }

            if let subText = subscriptionSwapText {
                Button(subText) {
                    Task(priority: .userInitiated) {
                        subscribeSwapping = true
                        let result = await swapSubscriptions()
                        subscribeSwapping = false
                        if result {
                            subscriptionSwapText = nil
                        } else {
                            subscriptionSwapText = "Retry"
                        }
                    }
                }
            }
            
            Button("Dismiss") {
                showCCAlert = false
                showCommunityChangeAlert = false
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 50, height: 50)
                .overlay { if subscribeSwapping { ProgressView() }}
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: UIScreen.main.bounds.size.width * 0.8, height: UIScreen.main.bounds.size.height * 0.5)
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    // TEMP
    func swapSubscriptions() async -> Bool {
        do {
            for account in accountsTracker.savedAccounts {
                
                // get community link for vlemmy
                let vlemmyResolution = try await APIClient().perform(request: ResolveObjectRequest(account: account,
                                                                                                   query: "https://vlemmy.net/c/mlemapp"))
                if let community = vlemmyResolution.community {
                    if !(await subscribe(account: account, communityId: community.community.id, shouldSubscribe: true)) {
                        return false
                    }
                }
                
                // get community link for lemmy.ml
                let mlResolution = try await APIClient().perform(request: ResolveObjectRequest(account: account,
                                                                                               query: "https://lemmy.ml/c/mlemapp"))
                if let community = mlResolution.community {
                    if !(await subscribe(account: account, communityId: community.community.id, shouldSubscribe: false)) {
                        return false
                    }
                }
            }
        } catch {
            return false
        }
        
        return true
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
