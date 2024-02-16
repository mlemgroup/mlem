//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import Dependencies
import SwiftUI

struct Window: View {
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    
    @Dependency(\.markReadBatcher) var markReadBatcher

    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @State var appState: AppState = {
        @Dependency(\.accountsTracker) var accountsTracker
        return AppState(apiSource: accountsTracker.defaultAccount)
    }()
    
    @State var loadedInitialFlow: Bool = false
    
    var body: some View {
        content
            .task(id: appState.actorId) {
                if appState.apiSource is any UserProviding {
                    if let host = appState.actorId?.host(),
                       let instance = RecognizedLemmyInstances(rawValue: host) {
                        easterFlagsTracker.setEasterFlag(.login(host: instance))
                    }
                } else {
                    do {
                        appState.myInstance = try await appState.instanceStub?.upgrade()
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
            .onChange(of: appState.apiSource?.actorId) {
                DispatchQueue.main.async {
                    Task {
                        await markReadBatcher.flush()
                    }
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
                .environmentObject(filtersTracker)
                .environmentObject(easterFlagsTracker)
                .environmentObject(layoutWidgetTracker)
        }
    }
}
