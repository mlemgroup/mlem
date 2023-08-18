//
//  Appearance.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

enum AppearanceSettingsNavigationRoute: Hashable, Codable {
    case theme
    case appIcon
    case posts
    case comments
    case communities
    case users
    case tabBar
}

struct AppearanceSettingsView: View {

    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        List {
            Section {
                NavigationLink(value: AppearanceSettingsNavigationRoute.theme) {
                    switch lightOrDarkMode {
                    case .unspecified:
                        ThemeLabel(title: "Theme", color1: .white, color2: .black)
                    case .light:
                        ThemeLabel(title: "Theme", color1: .white)
                    case .dark:
                        ThemeLabel(title: "Theme", color1: .black)
                    default:
                        ThemeLabel(title: "Theme", color1: .clear)
                    }
                }
#if !os(macOS) && !targetEnvironment(macCatalyst)
                NavigationLink(value: AppearanceSettingsNavigationRoute.appIcon) {
                    Label {
                        Text("App Icon")
                    } icon: {
                        IconSettingsView.getCurrentIcon()
                            .resizable()
                            .scaledToFit()
                            .frame(width: AppConstants.settingsIconSize, height: AppConstants.settingsIconSize)
                            .cornerRadius(AppConstants.smallItemCornerRadius)
                    }
                }
#endif
            }
            
            Section {
                NavigationLink(value: AppearanceSettingsNavigationRoute.posts) {
                    Label("Posts", systemImage: "doc.plaintext.fill").labelStyle(SquircleLabelStyle(color: .pink))
                }
                
                NavigationLink(value: AppearanceSettingsNavigationRoute.comments) {
                    Label("Comments", systemImage: "bubble.left.fill").labelStyle(SquircleLabelStyle(color: .orange))
                }
                
                NavigationLink(value: AppearanceSettingsNavigationRoute.communities) {
                    Label("Communities", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .green, fontSize: 15))
                }
                
                NavigationLink(value: AppearanceSettingsNavigationRoute.users) {
                    Label("Users", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .blue))
                }
            }
            Section {
                NavigationLink(value: AppearanceSettingsNavigationRoute.tabBar) {
                    Label("Tab Bar", systemImage: "square").labelStyle(SquircleLabelStyle(color: .purple))
                }
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Appearance")
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
    }
}
