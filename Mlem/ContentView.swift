//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appState: AppState

    @State private var errorAlert: ErrorAlert?
    @State private var tabSelection = 1

    @State var textToTranslate: String?
    @State private var showTranslate: Bool = false

    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true

    var body: some View {
        TabView(selection: $tabSelection) {
            AccountsPage()
                .tabItem {
                    Label("Feeds", systemImage: "text.bubble")
                }.tag(1)

            if let currentActiveAccount = appState.currentActiveAccount {
                InboxView(account: currentActiveAccount)
                    .tabItem {
                        Label("Inbox", systemImage: "mail.stack")
                    }.tag(2)

                NavigationView {
                    ProfileView(account: currentActiveAccount)
                } .tabItem {
                    if showUsernameInNavigationBar {
                        Label(currentActiveAccount.username, systemImage: "person")
                    } else {
                        Label("Profile", systemImage: "person")
                    }
                }.tag(3)
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(4)
        }
        .onAppear {
            AppConstants.keychain["test"] = "I-am-a-saved-thing"
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
        .environment(\.translateText, translateText)
        .sheet(isPresented: $showTranslate, content: {
            TranslationSheet(textToTranslate: $textToTranslate, shouldShow: $showTranslate)
        })
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }

    func translateText(_ text: String) {
        self.textToTranslate = text
        withAnimation {
            showTranslate = true
        }
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
