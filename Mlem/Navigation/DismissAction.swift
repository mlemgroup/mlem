//
//  DismissAction.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation
import SwiftUI

// MARK: - Navigation
final class Navigation: ObservableObject {
    var dismiss: DismissAction?
}

// MARK: - Hoist dismiss action
extension View {
    
    func hoistNavigation(dismiss: DismissAction) -> some View {
        modifier(NavigationDismissHoisting(dismiss: dismiss))
    }
}

struct NavigationDismissHoisting: ViewModifier {
    
    @EnvironmentObject private var navigation: Navigation
    
    /// - Note: Unfortunately, we can't access the dismiss action via View.environment...doing so causes SwiftUI to enter into infinite loop. [2023.09]
    let dismiss: DismissAction
    
    func body(content: Content) -> some View {
        content.onAppear {
            print("onAppear: navigate dismiss")
            navigation.dismiss = dismiss
        }
    }
}

// MARK: - Enable tab bar navigation
extension View {
    
    /// Unconditionally enable tab bar navigation.
    func tabBarNavigationEnabled(_ tab: TabSelection, _ navigator: Navigation) -> some View {
        modifier(PerformTabBarNavigation(tab: tab, navigator: navigator))
    }
}

struct PerformTabBarNavigation: ViewModifier {
    
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    let tab: TabSelection
    let navigator: Navigation
    
    func body(content: Content) -> some View {
        content.onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == tab.hashValue {
                print("perform tab navigation on \(tab) tab")
                navigator.dismiss?()
            }
        }
    }
}
