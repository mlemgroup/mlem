//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @State var navigationPath = NavigationPath()

    @Environment(\.openURL) private var openURL
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    NavigationLink(value: SettingsRoute.accountsPage(onboarding: false)) {
                        Label("Accounts", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .teal))
                    }
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
                        Label("Content Filters", systemImage: "line.3.horizontal.decrease").labelStyle(SquircleLabelStyle(color: .orange))
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
            .environment(\.navigationPath, $navigationPath)
            .fancyTabScrollCompatible()
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarColor()
            .navigationBarTitleDisplayMode(.inline)
            .useSettingsNavigationRouter()
        }
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.settings.hashValue {
                print("switched to Settings tab")
            }
        }
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.settings.hashValue {
                print("re-selected \(TabSelection.settings) tab")
                
            }
        }
    }
}
