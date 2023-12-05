//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @StateObject private var settingsTabNavigation: AnyNavigationPath<AppRoute> = .init()

    @Environment(\.openURL) private var openURL

    @Namespace var scrollToTop
    
    var body: some View {
        NavigationStack(path: $settingsTabNavigation.path) {
            ScrollViewReader { _ in
                List {
                    Section {
                        NavigationLink(.settings(.accounts)) {
                            Label("Accounts", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .teal))
                        }
                        .id(scrollToTop)
                    }
                    Section {
                        NavigationLink(.settings(.general)) {
                            Label("General", systemImage: "gear").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                        
                        NavigationLink(.settings(.sorting)) {
                            Label("Sorting", systemImage: "arrow.up.and.down.text.horizontal")
                                .labelStyle(SquircleLabelStyle(color: .indigo))
                        }
                        
                        NavigationLink(.settings(.contentFilters)) {
                            Label("Content Filters", systemImage: "line.3.horizontal.decrease")
                                .labelStyle(SquircleLabelStyle(color: .orange))
                        }
                        
                        NavigationLink(.settings(.accessibility)) {
                            // apparently the Apple a11y symbol isn't an SFSymbol
                            Label("Accessibility", systemImage: "hand.point.up.braille.fill").labelStyle(SquircleLabelStyle(color: .blue))
                        }
                        
                        NavigationLink(.settings(.appearance)) {
                            Label("Appearance", systemImage: "paintbrush.fill").labelStyle(SquircleLabelStyle(color: .pink))
                        }
                    }
                    
                    Section {
                        NavigationLink(.settings(.about)) {
                            Label("About Mlem", systemImage: "info").labelStyle(SquircleLabelStyle(color: .blue))
                        }
                    }
                    
                    Section {
                        NavigationLink(.settings(.advanced)) {
                            Label("Advanced", systemImage: "gearshape.2.fill").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                    }
                }
                .reselectAction(tab: TabSelection.settings) {
                    print("re-selected settings")
                }
            }
            .environmentObject(settingsTabNavigation)
            .fancyTabScrollCompatible()
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarColor()
            .navigationBarTitleDisplayMode(.inline)
        }
        .handleLemmyLinkResolution(navigationPath: .constant(settingsTabNavigation))
    }
}
