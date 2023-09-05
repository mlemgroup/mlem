//
//  UserSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//

import SwiftUI

struct UserSettingsView: View {
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("userIconShape") var communityIconShape: IconShape = .circle
    
    var body: some View {
        Form {
            Section {
                Toggle("Show Avatars", isOn: $shouldShowUserAvatars)
                if shouldShowUserAvatars {
                    HStack {
                        Text("Shape")
                            .accessibilityHidden(true)
                        Spacer()
                        Picker("Avatar Shape", selection: $communityIconShape) {
                            Image(systemName: "circle.fill")
                                .tag(IconShape.circle)
                                .accessibilityLabel("Circle")
                            Image(systemName: "square.fill")
                                .tag(IconShape.square)
                                .accessibilityLabel("Square")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                }
            }
            Section {
                Toggle("Show Banners", isOn: $shouldShowUserHeaders)
            } footer: {
                Text("Show a user's banner on their profile.")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Users")
    }
}
