//
//  Window.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Dependencies
import SwiftUI

struct Window: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @State var appFlow: AppFlow = {
        @Dependency(\.accountsTracker) var accountsTracker
        if let user = accountsTracker.defaultAccount {
            return .user(user)
        } else if let user = accountsTracker.savedAccounts.first {
            return .user(user)
        } else {
            print("ACCOUNTS TRACKER EMPTY")
            return .onboarding
        }
    }()
    
    var body: some View {
        content
            .environment(\.setAppFlow) { appFlow = $0 }
    }
    
    @ViewBuilder
    private var content: some View {
        switch appFlow {
        case .onboarding:
            LandingPage()
        case let .user(user):
            ContentView(user: user)
        case .guest:
            Text("Not yet!")
        }
    }
}
