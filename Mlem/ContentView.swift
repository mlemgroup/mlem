//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View
{
    
    @EnvironmentObject var appState: AppState
    
    @State private var errorAlert: ErrorAlert?

    @State var textToTranslate: String?
    @State private var showTranslate: Bool = false

    var body: some View
    {
        TabView
        {
            AccountsPage()
                .tabItem
                {
                    Label("Feeds", systemImage: "text.bubble")
                }
            
            if let currentActiveAccount = appState.currentActiveAccount
            {
                VStack {
                    Spacer()
                    Text("Messages is not yet implemented.  Coming soon!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text(verbatim: "\(currentActiveAccount.username): \(currentActiveAccount.id)")
                    Spacer()
                }.tabItem {
                    Label("Messages", systemImage: "mail.stack")
                }
                
                UserView(userID: currentActiveAccount.id, account: currentActiveAccount)
                    .tabItem {
                        Label(currentActiveAccount.username, systemImage: "person")
                    }
            }
            
            SettingsView()
                .tabItem
                {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear
        {
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
        self.textToTranslate = text//text
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
