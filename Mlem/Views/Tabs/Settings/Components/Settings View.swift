//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var appState: AppState
    @State var navigationPath = NavigationPath()

    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    NavigationLink {
                        AccountsPage(onboarding: false)
                    } label: {
                        Label("Accounts", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                }
                Section {
                    NavigationLink {
                        GeneralSettingsView()
                    } label: {
                        Label("General", systemImage: "gear").labelStyle(SquircleLabelStyle(color: .gray))
                    }
                    
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("Appearance", systemImage: "paintbrush.fill").labelStyle(SquircleLabelStyle(color: .pink))
                    }

                    NavigationLink {
                        FiltersSettingsView()
                    } label: {
                        Label("Content Filters", systemImage: "line.3.horizontal.decrease").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                }
                
                Section {
                    NavigationLink {
                        AboutView(navigationPath: $navigationPath)
                    } label: {
                        Label("About Mlem", systemImage: "info").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                }
                
                Section {
                    NavigationLink {
                        AdvancedSettingsView()
                    } label: {
                        Label("Advanced", systemImage: "gearshape.2.fill").labelStyle(SquircleLabelStyle(color: .gray))
                    }
                }
            }
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)

        }
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
    }
}
