//
//  InstanceStubResolutionPage.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-03-22.
//

import MlemMiddleware
import SwiftUI
import Theming
import os

struct InstanceStubResolutionPage: View {
    @Environment(NavigationLayer.self) var navigation
    
    let stub: InstanceStub
    let targetPage: (Instance) -> NavigationPage
    
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
                refresh: fetchInstance
            ))
        } else {
            ProgressView()
                .task {
                    await fetchInstance()
                }
        }
    }
    
    @discardableResult
    func fetchInstance() async -> Bool {
        do {
            let instance = try await stub.getInstance()
            Logger.dev.info("Got instance \(instance.host), api host: \(instance.api.host)")
            navigation.replace(targetPage(instance))
            return true
        } catch {
            upgradeError = error
            return false
        }
    }
}
