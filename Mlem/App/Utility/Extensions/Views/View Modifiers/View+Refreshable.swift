//
//  View+Refreshable.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-18.
//

import Foundation
import SwiftUI

struct RefreshableWrapperView: ViewModifier {
    let isEnabled: Bool

    let refreshAction: @Sendable () async -> Void

    func body(content: Content) -> some View {
        RefreshToggling(isEnabled: isEnabled, content: content)
            .refreshable(action: refreshAction)
    }
}

private struct RefreshToggling<Content: View>: View {
    @Environment(\.refresh) private var refresh
    let isEnabled: Bool

    let content: Content

    var body: some View {
        content
            .environment(EnvironmentValues.safeWritableRefreshKeyPath, isEnabled ? refresh : nil)
    }
}

private struct RefreshCastFailsafeKey: EnvironmentKey {
    static let defaultValue: RefreshAction? = nil
}

private extension EnvironmentValues {
    static let safeWritableRefreshKeyPath: WritableKeyPath<EnvironmentValues, RefreshAction?> = {
        guard let keyPath = \EnvironmentValues.refresh as? WritableKeyPath<EnvironmentValues, RefreshAction?> else {
            handleError(MlemError.modelError("Using refreshFailsafe - .refreshable isn't working!"), silent: true)
            return \.refreshFailsafe
        }
        return keyPath
    }()

    var refreshFailsafe: RefreshAction? {
        get { self[RefreshCastFailsafeKey.self] }
        set { self[RefreshCastFailsafeKey.self] = newValue }
    }
}

public extension View {
    func refreshable(isEnabled: Bool, _ operation: @escaping @Sendable () async -> Void) -> some View {
        modifier(RefreshableWrapperView(isEnabled: isEnabled, refreshAction: operation))
    }
}
