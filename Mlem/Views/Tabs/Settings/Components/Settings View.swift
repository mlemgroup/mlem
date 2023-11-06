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
    @StateObject private var navigation: Navigation = .init()

    @Environment(\.openURL) private var openURL
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    @Environment(\.dismiss) private var dismiss
    
    @Namespace var scrollToTop
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $settingsTabNavigation.path) {
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
                .tabBarNavigationEnabled(.settings, navigation)
                .environmentObject(settingsTabNavigation)
                .fancyTabScrollCompatible()
                .handleLemmyViews()
                .navigationTitle("Settings")
                .navigationBarColor()
                .navigationBarTitleDisplayMode(.inline)
                .hoistNavigation(
                    dismiss: dismiss,
                    auxiliaryAction: {
                        withAnimation {
                            proxy.scrollTo(scrollToTop, anchor: .bottom)
                        }
                        return true
                    }
                )
            }
            .environmentObject(navigation)
            .handleLemmyLinkResolution(navigationPath: .constant(settingsTabNavigation))
            .onChange(of: selectedTagHashValue) { newValue in
                if newValue == TabSelection.settings.hashValue {
                    print("switched to Settings tab")
                }
            }
            .fancyTabScrollCompatible()
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarColor()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
