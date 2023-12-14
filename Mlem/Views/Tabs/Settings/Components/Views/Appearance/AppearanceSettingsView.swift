//
//  AppearanceSettingsView.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        List {
            Section {
                NavigationLink(.appearanceSettings(.theme)) {
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
                NavigationLink(.appearanceSettings(.appIcon)) {
                        Label {
                            Text("App Icon")
                        } icon: {
                            IconSettingsView.getCurrentIcon()
                                .resizable()
                                .scaledToFit()
                                .frame(width: AppConstants.settingsIconSize, height: AppConstants.settingsIconSize)
                                .cornerRadius(AppConstants.smallItemCornerRadius)
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                                        .stroke(Color(.secondarySystemBackground), lineWidth: 1)
                                }
                        }
                    }
                #endif
            }
            
            Section {
                NavigationLink(.appearanceSettings(.posts)) {
                    Label("Posts", systemImage: "doc.plaintext.fill").labelStyle(SquircleLabelStyle(color: .pink))
                }
                
                NavigationLink(.appearanceSettings(.comments)) {
                    Label("Comments", systemImage: "bubble.left.fill").labelStyle(SquircleLabelStyle(color: .orange))
                }
                
                NavigationLink(.appearanceSettings(.communities)) {
                    Label("Communities", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .green, fontSize: 15))
                }
                
                NavigationLink(.appearanceSettings(.users)) {
                    Label("Users", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .blue))
                }
            }
            Section {
                NavigationLink(.appearanceSettings(.tabBar)) {
                    Label("Tab Bar", systemImage: "square").labelStyle(SquircleLabelStyle(color: .purple))
                }
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Appearance")
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
        .hoistNavigation()
    }
}
