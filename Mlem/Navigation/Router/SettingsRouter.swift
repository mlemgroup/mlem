//
//  SettingsRouter.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import SwiftUI

extension View {
    func useSettingsNavigationRouter() -> some View {
        modifier(SettingsRouter())
            .modifier(AppearanceSettingsRouter())
            .modifier(CommentSettingsRouter())
            .modifier(PostSettingsRouter())
            .modifier(AboutSettingsRouter())
            .modifier(LicensesSettingsRouter())
    }
}

struct SettingsRouter: ViewModifier {
    @Environment(\.navigationPath) private var navigationPath
    @EnvironmentObject private var layoutWidgetTracker: LayoutWidgetTracker

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case let .accountsPage(onboarding):
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
    }
}

private struct AppearanceSettingsRouter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppearanceSettingsRoute.self) { route in
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
    }
}

private struct CommentSettingsRouter: ViewModifier {
    @EnvironmentObject private var layoutWidgetTracker: LayoutWidgetTracker
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: CommentSettingsRoute.self) { route in
                switch route {
                case .layoutWidget:
                    LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.comment, onSave: { widgets in
                        layoutWidgetTracker.groups.comment = widgets
                        layoutWidgetTracker.saveLayoutWidgets()
                    })
                }
            }
    }
}

private struct PostSettingsRouter: ViewModifier {
    @EnvironmentObject private var layoutWidgetTracker: LayoutWidgetTracker

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: PostSettingsRoute.self) { route in
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
}

private struct AboutSettingsRouter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AboutSettingsRoute.self) { route in
                switch route {
                case .contributors:
                    ContributorsView()
                case let .eula(doc):
                    DocumentView(text: doc.body)
                case let .privacyPolicy(doc):
                    DocumentView(text: doc.body)
                case .licenses:
                    LicensesView()
                }
            }
    }
}

private struct LicensesSettingsRouter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: LicensesSettingsRoute.self) { route in
                switch route {
                case let .licenseDocument(doc):
                    DocumentView(text: doc.body)
                }
            }
    }
}
