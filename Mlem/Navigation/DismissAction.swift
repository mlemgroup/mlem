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
    
    /// Return `true` to indicate that an auxiliary action was performed.
    typealias AuxiliaryAction = () -> Bool
    
    /// Navigation always performs dismiss action (if available), but may choose to perform an auxiliary action first.
    ///
    /// This action includes support for popping back to sidebar view in a `NavigationSplitView`.
    var dismiss: DismissAction?
    /// An auxiliary action may consist of multiple sub-actions: To do so, simply configure this action to return false once all sub-actions have been (or can no longer be) performed.
    ///
    /// - Warning: Navigation may skip this action, depending on user preference or other factors. Do not perform critical logic in this action.
    var auxiliaryAction: AuxiliaryAction?
}

// MARK: - Hoist dismiss action
extension View {
    
    func hoistNavigation(
        dismiss: DismissAction,
        auxiliaryAction: Navigation.AuxiliaryAction? = nil
    ) -> some View {
        modifier(
            NavigationDismissHoisting(
                dismiss: dismiss,
                auxiliaryAction: auxiliaryAction
            )
        )
    }
}

struct NavigationDismissHoisting: ViewModifier {
    
    @EnvironmentObject private var navigation: Navigation
    
    /// - Note: Unfortunately, we can't access the dismiss action via View.environment...doing so causes SwiftUI to enter into infinite loop. [2023.09]
    let dismiss: DismissAction
    let auxiliaryAction: Navigation.AuxiliaryAction?
    
    func body(content: Content) -> some View {
        content.onAppear {
            print("hoist navigation dismiss action")
            navigation.dismiss = dismiss
            navigation.auxiliaryAction = auxiliaryAction
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
                if let auxiliaryAction = navigator.auxiliaryAction {
                    let performed = auxiliaryAction()
                    if !performed, let dismiss = navigator.dismiss {
                        print("found auxiliary action, but that logic has been exhausted...perform standard dismiss action")
                        print("perform tab navigation on \(tab) tab")
                        dismiss()
                    } else {
                        print("performed auxiliary action")
                    }
                } else if let dismiss = navigator.dismiss {
                    print("perform tab navigation on \(tab) tab")
                    dismiss()
                } else {
                    print("attempted tab navigation -> action(s) not found")
                }
            }
        }
    }
}
