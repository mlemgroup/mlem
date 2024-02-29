//
//  Window.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Dependencies
import SwiftUI

enum AppFlow {
    case onboarding
    case guest(InstanceStub)
    case user(UserStub)
}

struct Window: View {
    @Dependency(\.errorHandler) var errorHandler
    
//    @State var onboarding: Bool = {
//        @Dependency(\.accountsTracker) var accountsTracker
//        return accountsTracker.savedAccounts.isEmpty
//    }()
    
    @State var appFlow: AppFlow = {
        @Dependency(\.accountsTracker) var accountsTracker
        if let user = accountsTracker.defaultAccount {
            return .user(user)
        } else {
            assert(accountsTracker.savedAccounts.isEmpty, "Accounts saved but no default exists!")
            return .onboarding
        }
    }()
    
    var body: some View {
        content
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
