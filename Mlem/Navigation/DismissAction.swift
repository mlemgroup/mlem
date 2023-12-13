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
    
    enum PrimaryAction {
        case dismiss
    }
    
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

// MARK: - Navigation Behaviour
extension Navigation {
    
    enum Behaviour {
        /// Mimics Apple platforms tab bar navigation behaviour (i.e. pop to root regardless of navigation stack size, then scroll to top).
        case system
        /// Only perform the primary action for navigation (this defaults to dismiss action).
        case primary
        /// Perform the auxiliary action(s) first, if specified, before proceeding with the primary action.
        case primaryAuxiliary
    }
}

// MARK: - Hoist dismiss action
extension View {
    
    /// - Parameter dismiss: Pass in the `@Environment(\.dismiss)` property declared in the view being modified.
    /// - Note: See `hoistNavigation(_ primaryAction:...)`, if declaring dismiss action in your view causes SwiftUI to enter an infinite loop.
    func hoistNavigation(
        dismiss: DismissAction,
        auxiliaryAction: Navigation.AuxiliaryAction? = nil
    ) -> some View {
        // TODO: Possibly allow injection. If not, deprecate and remove this function.
        modifier(
            NavigationDismissHoisting(
                auxiliaryAction: auxiliaryAction
            )
        )
    }
    
    /// This view modifier variant manages the primary action on behalf of caller.
    ///
    /// In some view configurations, declaring the `@Environment(\.dismiss)` property may cause SwiftUI to enter an infinite loop. If so, use this view modifier, instead.
    func hoistNavigation(
        _ primaryAction: Navigation.PrimaryAction = .dismiss,
        auxiliaryAction: Navigation.AuxiliaryAction? = nil
    ) -> some View {
        modifier(
            NavigationDismissHoisting(
                auxiliaryAction: auxiliaryAction
            )
        )
    }
}

/// `NavigationDismissView` works around an issue where adding an `@Environment(\.dismiss)` property in some view configurations causes SwiftUI to enter infinite loop.
///
/// Technical Note:
/// - Note: In some configurations, declaring the `@Environment(\.dismiss) var` inside a view modifier causes SwiftUI to enter into infinite loop. [2023.09]
/// - Note: This view allows us to conditionally move where we declare the dismiss action, if some view (modifier) configuration causes SwiftUI to enter infinite loop. [2023.11]
private struct NavigationDismissView<Content: View>: View {
    
    @Environment(\.dismiss) private var dismissAction
    private let content: (DismissAction) -> Content
    
    init(@ViewBuilder content: @escaping (DismissAction) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(dismissAction)
    }
}

struct NavigationDismissHoisting: ViewModifier {
    
    private typealias AnyRoute = any Hashable
    
    @EnvironmentObject private var navigation: Navigation
    
    @Environment(\.navigationPathWithRoutes) private var routesNavigationPath
    
    @Environment(\.tabSelectionHashValue) private var selectedTabHashValue
    
    private var navigationPath: [AnyRoute] {
        guard let selectedTabHashValue else {
            return []
        }
        guard selectedTabHashValue.hashValue != TabSelection._tabBarNavigation.hashValue else {
            assertionFailure()
            return []
        }
        return routesNavigationPath.wrappedValue
    }
    
    let auxiliaryAction: Navigation.AuxiliaryAction?
    
    @State private var didAppear = false
    
    func body(content: Content) -> some View {
        NavigationDismissView { dismiss in
            content
                .onAppear {
                    defer { didAppear = true }
                    
                    /// This must only be called once:
                    /// For example, user may wish to drag to peek at the previous view, but then cancel that drag action. During this, the previous view's .onAppear will get called. If we run this logic for that view again, the actual top view's dismiss action will get lost. [2023.09]
                    if didAppear == false {
                        #if DEBUG
                        print("onAppear: hoist navigation dismiss action")
                        #endif
                        navigation.dismiss = dismiss
                        navigation.auxiliaryAction = auxiliaryAction
                        let pathIndex = max(0, navigationPath.count)
                        #if DEBUG
                        print("     adding path action at index -> \(pathIndex)")
                        #endif
                        navigation.pathActions[pathIndex] = (dismiss, auxiliaryAction)
                        #if DEBUG
                        print("     navigation -> \(Unmanaged.passUnretained(navigation).toOpaque())")
                        #endif
                    }
                }
                .onDisappear {
                    #if DEBUG
                    print("onDisappear: path count -> \(navigationPath.count), action count -> \(navigation.pathActions.count)")
                    print("     navigation -> \(Unmanaged.passUnretained(navigation).toOpaque())")
                    #endif
                    
                    let removeIndex = navigationPath.count + 1
                    // swiftlint:disable unused_optional_binding
                    if let _ = navigation.pathActions.removeValue(forKey: removeIndex) {
                        #if DEBUG
                        // swiftlint:enable unused_optional_binding
                        print("     removed path action at index -> \(removeIndex)")
                        #endif
                    } else {
                        #if DEBUG
                        print("     no path action to remove at index -> \(removeIndex)")
                        #endif
                    }
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
        return routesNavigationPath.wrappedValue
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
        #if DEBUG
        print("perform action on path index -> \(navigationPath.count)")
        #endif
        guard let pathAction = navigator.pathActions[navigationPath.count] else {
            #if DEBUG
            print("path action not found at index -> \(navigationPath.count)")
            #endif
            return
        }
        
        if let auxiliaryAction = pathAction.auxiliaryAction {
            let performed = auxiliaryAction()
            if !performed, let dismiss = pathAction.dismiss {
                #if DEBUG
                print("found auxiliary action, but that logic has been exhausted...perform standard dismiss action")
                print("perform tab navigation on \(tab) tab")
                #endif
                dismiss()
            } else {
                #if DEBUG
                print("performed auxiliary action")
                #endif
            }
        } else if let dismiss = pathAction.dismiss {
            #if DEBUG
            print("perform dismiss action via tab navigation on \(tab) tab")
            #endif
            dismiss()
        } else {
            #if DEBUG
            print("attempted tab navigation -> action(s) not found")
            #endif
        }
    }
}
