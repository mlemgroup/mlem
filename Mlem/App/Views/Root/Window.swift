//
//  Window.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Dependencies
import SwiftUI

/// This view
struct Window: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
    
    @State var appState: AppState = {
        @Dependency(\.accountsTracker) var accountsTracker
        return AppState(apiSource: accountsTracker.defaultAccount)
    }()
    
    @State var loadedInitialFlow: Bool = false
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        content
            .task(id: appState.actorId) {
                do {
                    appState.myInstance = try await appState.instanceStub?.upgrade()
                } catch {
                    errorHandler.handle(error)
                }
            }
            .onAppear {
                if !loadedInitialFlow {
                    hapticManager.initEngine()
                    loadedInitialFlow = true
                }
            }
            .environment(appState)
            .onReceive(timer) { _ in
                print("Clearing caches...")
                appState.apiSource?.caches.clean()
                Instance1.cache.clean()
                Instance2.cache.clean()
                Instance3.cache.clean()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if appState.isOnboarding {
            Text("Onboarding broken :(")
            // LandingPage()
        } else {
            ContentView()
                .environmentObject(layoutWidgetTracker)
        }
    }
}
