//
//  View+ReloadOnAccountSwitch.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-10.
//

import MlemMiddleware
import SwiftUI

private struct ReloadOnAccountSwitchModifier<T: UnifiedModelProviding & ContentIdentifiable>: ViewModifier {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Binding var entity: T
    @Binding var isLoading: Bool
    var callback: ((T) -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: appState.firstApi) {
                isLoading = true
                Task {
                    do {
                        let newEntity = try await entity.resolve(with: appState.firstApi)
                        callback?(newEntity)
                        Task { @MainActor in
                            entity = newEntity
                            isLoading = false
                        }
                    } catch {
                        handleError(error)
                        Task { @MainActor in isLoading = false }
                    }
                }
            }
    }
}

extension View {
    func reloadOnAccountSwitch<T: UnifiedModelProviding & ContentIdentifiable>(
        entity: Binding<T>,
        isLoading: Binding<Bool>,
        callback: ((T) -> Void)? = nil) -> some View {
        modifier(ReloadOnAccountSwitchModifier(entity: entity, isLoading: isLoading, callback: callback))
    }
}
