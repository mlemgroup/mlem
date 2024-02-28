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
    
    @State var onboarding: Bool = {
        @Dependency(\.accountsTracker) var accountsTracker
        return accountsTracker.savedAccounts.isEmpty
    }()
    
    var body: some View {
        content
    }
    
    @ViewBuilder
    private var content: some View {
        if onboarding {
            LandingPage()
        } else {
            ContentView()
        }
    }
}
