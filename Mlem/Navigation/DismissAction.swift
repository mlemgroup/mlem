//
//  DismissAction.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Dependencies
import Foundation
import SwiftUI

// MARK: - Navigation
final class Navigation: ObservableObject {
    
    /// Return `true` to indicate that an auxiliary action was performed.
    typealias AuxiliaryAction = () -> Bool
    
    var pathActions: [Int: (dismiss: DismissAction?, auxiliaryAction: AuxiliaryAction?)] = [:]
    
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
    
    private typealias AnyRoute = any Hashable
    
    @EnvironmentObject private var navigation: Navigation
    
    @Environment(\.navigationPathWithRoutes) private var routesNavigationPath
    @Environment(\.settingsRoutesNavigationPath) private var settingsNavigationPath
    
    @Environment(\.tabSelectionHashValue) private var selectedTabHashValue
    
    private var navigationPath: [AnyRoute] {
        guard let selectedTabHashValue else {
            return []
        }
        guard selectedTabHashValue.hashValue != TabSelection._tabBarNavigation.hashValue else {
            assertionFailure()
            return []
        }
        if selectedTabHashValue == TabSelection.settings.hashValue {
            return settingsNavigationPath.wrappedValue
        } else {
            return routesNavigationPath.wrappedValue
        }
    }
    
    /// - Note: Unfortunately, we can't access the dismiss action via View.environment...doing so causes SwiftUI to enter into infinite loop. [2023.09]
    let dismiss: DismissAction
    let auxiliaryAction: Navigation.AuxiliaryAction?
    
    @State private var didAppear = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                defer { didAppear = true }
                
                /// This must only be called once:
                /// For example, user may wish to drag to peek at the previous view, but then cancel that drag action. During this, the previous view's .onAppear will get called. If we run this logic for that view again, the actual top view's dismiss action will get lost. [2023.09]
                if didAppear == false {
                    print("onAppear: hoist navigation dismiss action")
                    navigation.dismiss = dismiss
                    navigation.auxiliaryAction = auxiliaryAction
                    let pathIndex = max(0, navigationPath.count)
                    print("     adding path action at index -> \(pathIndex)")
                    navigation.pathActions[pathIndex] = (dismiss, auxiliaryAction)
                    print("     navigation -> \(Unmanaged.passUnretained(navigation).toOpaque())")
                }
            }
            .onDisappear {
                print("onDisappear: path count -> \(navigationPath.count), action count -> \(navigation.pathActions.count)")
                print("     navigation -> \(Unmanaged.passUnretained(navigation).toOpaque())")
                let removeIndex = navigationPath.count + 1
                // swiftlint:disable unused_optional_binding
                if let _ = navigation.pathActions.removeValue(forKey: removeIndex) {
                    // swiftlint:enable unused_optional_binding
                    print("     removed path action at index -> \(removeIndex)")
                } else {
                    print("     no path action to remove at index -> \(removeIndex)")
                }
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
    
    private typealias AnyRoute = any Hashable
    
    @Dependency(\.hapticManager) private var hapticManager
    
    @Environment(\.navigationPathWithRoutes) private var routesNavigationPath
    @Environment(\.settingsRoutesNavigationPath) private var settingsNavigationPath
    
    @Environment(\.tabSelectionHashValue) private var selectedTabHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    private var navigationPath: [AnyRoute] {
        guard let selectedTabHashValue else {
            return []
        }
        guard selectedTabHashValue.hashValue != TabSelection._tabBarNavigation.hashValue else {
            assertionFailure()
            return []
        }
        if selectedTabHashValue == TabSelection.settings.hashValue {
            return settingsNavigationPath.wrappedValue
        } else {
            return routesNavigationPath.wrappedValue
        }
    }
    
    let tab: TabSelection
    let navigator: Navigation
    
    func body(content: Content) -> some View {
        content.onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == tab.hashValue {
                hapticManager.play(haptic: .gentleInfo, priority: .high)
                // Customization based  on user preference should occur here, for example:
                // performSystemPopToRootBehaviour()
                // noOp()
                // performDimsissOnly()
                performDismissAfterAuxiliary()
            }
        }
    }
    
    /// Runs all auxiliary actions before calling system dismiss action.
    private func performDismissAfterAuxiliary() {
        print("perform action on path index -> \(navigationPath.count)")
        guard let pathAction = navigator.pathActions[navigationPath.count] else {
            print("path action not found at index -> \(navigationPath.count)")
            return
        }
        
        if let auxiliaryAction = pathAction.auxiliaryAction {
            let performed = auxiliaryAction()
            if !performed, let dismiss = pathAction.dismiss {
                print("found auxiliary action, but that logic has been exhausted...perform standard dismiss action")
                print("perform tab navigation on \(tab) tab")
                dismiss()
            } else {
                print("performed auxiliary action")
            }
        } else if let dismiss = pathAction.dismiss {
            print("perform dismiss action via tab navigation on \(tab) tab")
            dismiss()
        } else {
            print("attempted tab navigation -> action(s) not found")
        }
    }
}
