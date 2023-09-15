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
    }
}

struct SettingsRouter: ViewModifier {
    @Environment(\.navigationPath) private var navigationPath
    @EnvironmentObject private var layoutWidgetTracker: LayoutWidgetTracker

    // swiftlint:disable cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .accountsPage:
                    AccountsPage()
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
                case .aboutPage(let path):
                    aboutPageDestination(for: path)
                case .appearancePage(let path):
                    appearancePageDestination(for: path)
                case .commentPage(let path):
                    commentPageDestination(for: path)
                case .postPage(let path):
                    postPageDestination(for: path)
                case .licensesPage(let path):
                    licensesPageDestination(for: path)
                }
            }
    }
    // swiftlint:enable cyclomatic_complexity
    
    @ViewBuilder
    private func aboutPageDestination(for path: AboutSettingsRoute) -> some View {
        switch path {
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
    
    @ViewBuilder
    private func appearancePageDestination(for path: AppearanceSettingsRoute) -> some View {
        switch path {
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
    
    @ViewBuilder
    private func commentPageDestination(for path: CommentSettingsRoute) -> some View {
        switch path {
        case .layoutWidget:
            LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.comment, onSave: { widgets in
                layoutWidgetTracker.groups.comment = widgets
                layoutWidgetTracker.saveLayoutWidgets()
            })
        }
    }
    
    @ViewBuilder
    private func postPageDestination(for path: PostSettingsRoute) -> some View {
        switch path {
        case .customizeWidgets:
            /// We really should be passing in the layout widget through the route enum value, but that would involve making layout widget tracker hashable and codable.
            LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.post, onSave: { widgets in
                layoutWidgetTracker.groups.post = widgets
                layoutWidgetTracker.saveLayoutWidgets()
            })
        }
    }
    
    @ViewBuilder
    private func licensesPageDestination(for path: LicensesSettingsRoute) -> some View {
        switch path {
        case let .licenseDocument(doc):
            DocumentView(text: doc.body)
        }
    }
}
