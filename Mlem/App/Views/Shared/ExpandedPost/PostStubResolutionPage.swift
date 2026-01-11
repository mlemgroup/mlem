//
//  PostPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/09/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

struct PostStubResolutionPage: View {
    @Environment(NavigationLayer.self) var navigation
    
    let stub: any PostStubProviding
    
    @State var upgradeError: Error?
    
    var body: some View {
        if let upgradeError {
            ErrorView(.init(error: upgradeError))
        } else {
            ProgressView()
                .task {
                    do {
                        let upgraded = try await stub.newUpgrade()
                        navigation.replace(.post(upgraded))
                    } catch {
                        upgradeError = error
                    }
                }
        }
    }
}
