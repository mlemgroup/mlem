//
//  CommunityStubResolutionPage.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-20.
//

import MlemMiddleware
import SwiftUI
import Theming

struct CommunityStubResolutionPage: View {
    @Environment(NavigationLayer.self) var navigation
    
    let stub: CommunityStub
    
    @State var upgradeError: Error?
    
    var body: some View {
        content
            .themedGroupedBackground()
    }
    
    @ViewBuilder
    var content: some View {
        if let upgradeError {
            ErrorView(.init(
                error: upgradeError,
                refresh: fetchCommunity
            ))
        } else {
            ProgressView()
                .task {
                    await fetchCommunity()
                }
        }
    }
    
    @discardableResult
    func fetchCommunity() async -> Bool {
        do {
            let community = try await stub.getCommunity()
            navigation.replace(.community(community, visitContext: .other))
            return true
        } catch {
            upgradeError = error
            return false
        }
    }
}
