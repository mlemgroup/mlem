//
//  View+NavigationEnvironment.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-11.
//

import Foundation
import SwiftUI

private struct NavigationEnvironment: ViewModifier {
    let navigationLayer: NavigationLayer
    
    func body(content: Content) -> some View {
        content
            .environment(navigationLayer)
            .environment(\.navigationContext, navigationLayer)
    }
}

extension View {
    /// Adds the given navigationLayer to the environment
    func navigationEnvironment(_ navigationLayer: NavigationLayer) -> some View {
        modifier(NavigationEnvironment(navigationLayer: navigationLayer))
    }
}
