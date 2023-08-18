//
//  NavigationRouter.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import SwiftUI

extension View {
    func useSettingsNavigationRouter() -> some View {
        modifier(SettingsNavigationRouter())
    }
}

struct SettingsNavigationRouter: ViewModifier {
    
    @Environment(\.navigationPath) private var navigationPath
    @EnvironmentObject private var layoutWidgetTracker: LayoutWidgetTracker

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SettingsNavigationRoute.self) { route in
                switch route {
                case .accountsPage(let onboarding):
                    AccountsPage(onboarding: onboarding)
                case .general:
                    GeneralSettingsView()
                case .accessibility:
                    AccessibilitySettingsView()
                case .appearance:
                    AppearanceSettingsView()
                case .contentFilters:
                    FiltersSettingsView()
                case .about:
                    AboutView(navigationPath: navigationPath)
                case .advanced:
                    AdvancedSettingsView()
                }
            }
            .navigationDestination(for: AppearanceSettingsNavigationRoute.self) { route in
                switch route {
                case .theme:
                    ThemeSettingsView()
                case .appIcon:
                    IconSettingsView()
                case .posts:
                    PostSettingsView()
                case .comments:
                    CommentSettingsView()
                case .communities:
                    CommunitySettingsView()
                case .users:
                    UserSettingsView()
                case .tabBar:
                    TabBarSettingsView()
                }
            }
            .navigationDestination(for: CommentSettingsNavigationRoute.self) { route in
                switch route {
                case .layoutWidget:
                    LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.comment, onSave: { widgets in
                        layoutWidgetTracker.groups.comment = widgets
                        layoutWidgetTracker.saveLayoutWidgets()
                    })
                }
            }
            .navigationDestination(for: PostSettingsNavigationRoute.self) { route in
                switch route {
                case .customizeWidgets:
                    /// We really should be passing in the layout widget through the route enum value, but that would involve making layout widget tracker hashable and codable.
                    LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.post, onSave: { widgets in
                        layoutWidgetTracker.groups.post = widgets
                        layoutWidgetTracker.saveLayoutWidgets()
                    })
                }
            }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}
