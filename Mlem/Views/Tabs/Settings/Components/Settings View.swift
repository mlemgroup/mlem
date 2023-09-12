//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @StateObject private var settingsRouter: NavigationRouter<SettingsRoute> = .init()
    @StateObject private var navigation: Navigation = .init()

    @Environment(\.openURL) private var openURL
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    @Namespace var scrollToTop
    
    var body: some View {
        NavigationStack(path: $settingsRouter.path) {
            ScrollViewReader { _ in
                List {
                    Section {
                        NavigationLink(value: SettingsRoute.accountsPage) {
                            Label("Accounts", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .teal))
                        }
                        .id(scrollToTop)
                    }
                    Section {
                        NavigationLink(value: SettingsRoute.general) {
                            Label("General", systemImage: "gear").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                        
                        NavigationLink(value: SettingsRoute.accessibility) {
                            // apparently the Apple a11y symbol isn't an SFSymbol
                            Label("Accessibility", systemImage: "hand.point.up.braille.fill").labelStyle(SquircleLabelStyle(color: .blue))
                        }
                        
                        NavigationLink(value: SettingsRoute.appearance) {
                            Label("Appearance", systemImage: "paintbrush.fill").labelStyle(SquircleLabelStyle(color: .pink))
                        }
                        
                        NavigationLink(value: SettingsRoute.contentFilters) {
                            Label("Content Filters", systemImage: "line.3.horizontal.decrease")
                                .labelStyle(SquircleLabelStyle(color: .orange))
                        }
                    }
                    
                    Section {
                        NavigationLink(value: SettingsRoute.about) {
                            Label("About Mlem", systemImage: "info").labelStyle(SquircleLabelStyle(color: .blue))
                        }
                    }
                    
                    Section {
                        NavigationLink(value: SettingsRoute.advanced) {
                            Label("Advanced", systemImage: "gearshape.2.fill").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                    }
                }
                .tabBarNavigationEnabled(.settings, navigation)
            }
            .environmentObject(settingsRouter)
            .fancyTabScrollCompatible()
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarColor()
            .navigationBarTitleDisplayMode(.inline)
            .useSettingsNavigationRouter()
        }
        .environmentObject(navigation)
        .handleLemmyLinkResolution(navigationPath: .constant(settingsRouter))
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.settings.hashValue {
                print("switched to Settings tab")
            }
        }
    }
}
