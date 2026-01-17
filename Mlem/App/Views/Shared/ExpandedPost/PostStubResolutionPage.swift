//
//  PostStubResolutionPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/09/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

// TODO: NOW just make this an ExpectedView?
// Or expanded post page itself take expectedValue...?

struct PostStubResolutionPage: View {
    @Environment(NavigationLayer.self) var navigation
    
    let stub: PostStub
    
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
                refresh: fetchPost
            ))
        } else {
            ProgressView()
                .task {
                    await fetchPost()
                }
        }
    }
    
    @discardableResult
    func fetchPost() async -> Bool {
        do {
            let upgraded = try await stub.upgrade()
            navigation.replace(.post(upgraded))
            return true
        } catch {
            upgradeError = error
            return false
        }
    }
}
