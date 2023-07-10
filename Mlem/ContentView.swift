//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker

    @State private var errorAlert: ErrorAlert?
    @State private var tabSelection = 1

    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero

    var body: some View {
        ZStack {
            List {
                Button("beehaw.org") {
                    withAnimation {
                        dragPosition = .zero
                    }
                }
                Button("lemmy.ml") {
                    withAnimation {
                        dragPosition = .zero
                    }
                }
            }
            
            TabView(selection: $tabSelection) {
                FeedRoot()
                    .tabItem {
                        Label("Feeds", systemImage: "scroll")
                            .environment(\.symbolVariants, tabSelection == 1 ? .fill : .none)
                    }.tag(1)
                
                if let currentActiveAccount = appState.currentActiveAccount {
                    InboxView(account: currentActiveAccount)
                        .tabItem {
                            Label("Inbox", systemImage: "mail.stack")
                                .environment(\.symbolVariants, tabSelection == 2 ? .fill : .none)
                        }.tag(2)
                    
                    NavigationView {
                        ProfileView(account: currentActiveAccount)
                    } .tabItem {
                        Label(computeUsername(account: currentActiveAccount), systemImage: "person.circle")
                            .environment(\.symbolVariants, tabSelection == 3 ? .fill : .none)
                    }.tag(3)
                    
                    NavigationView {
                        SearchView(account: currentActiveAccount)
                    } .tabItem {
                        Label("Search", systemImage: tabSelection == 4 ? "text.magnifyingglass" : "magnifyingglass")
                    }.tag(4)
                }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                            .environment(\.symbolVariants, tabSelection == 4 ? .fill : .none)
                    }.tag(5)
            }
            .offset(y: dragPosition)
            .gesture(
                DragGesture()
                    .updating($dragState) { value, state, _ in
                        state = value.translation.height
                    }
            )
            .onChange(of: dragState) { newDragState in
                if newDragState == .zero {
                    if prevDragPosition < -100 {
                        withAnimation {
                            dragPosition = -1 * UIScreen.main.bounds.size.height
                        }
                    } else {
                        dragPosition = .zero
                    }
                } else {
                    dragPosition = newDragState
                    prevDragPosition = dragPosition
                }
            }
            .onAppear {
                if appState.currentActiveAccount == nil,
                   let account = accountsTracker.savedAccounts.first {
                    appState.currentActiveAccount = account
                }
            }
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(appState)
    }

    // MARK: helpers
    func computeUsername(account: SavedAccount) -> String {
        return showUsernameInNavigationBar ? account.username : "Profile"
    }
}

// MARK: - URL Handling

extension ContentView {
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        let outcome = URLHandler.handle(url)

        switch outcome.action {
        case let .error(message):
            errorAlert = .init(
                title: "Unsupported link",
                message: message
            )
        default:
            break
        }

        return outcome.result
    }
}
