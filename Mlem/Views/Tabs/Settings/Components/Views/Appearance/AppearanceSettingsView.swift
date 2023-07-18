//
//  Appearance.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct AppearanceSettingsView: View {

    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink {
                        ThemeSettingsView()
                    } label: {
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
                    NavigationLink {
                        IconSettingsView()
                    } label: {
                        Label {
                           Text("App Icon")
                        } icon: {
                            IconSettingsView.getCurrentIcon()
                                .resizable()
                                .scaledToFit()
                                .frame(width: AppConstants.settingsIconSize, height: AppConstants.settingsIconSize)
                                .cornerRadius(AppConstants.settingsIconCornerRadius)
                        }
                    }
                    #endif
                }
                
                Section {
                    NavigationLink {
                        PostSettingsView()
                    } label: {
                        Label("Posts", systemImage: "doc.plaintext.fill").labelStyle(SquircleLabelStyle(color: .pink))
                    }
                    
                    NavigationLink {
                        CommentSettingsView()
                    } label: {
                        Label("Comments", systemImage: "bubble.left.fill").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                    
                    NavigationLink {
                        CommunitySettingsView()
                    } label: {
                        Label("Communities", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .green, fontSize: 15))
                    }
                    
                    NavigationLink {
                        UserSettingsView()
                    } label: {
                        Label("Users", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                }
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
