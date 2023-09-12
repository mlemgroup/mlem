//
//  UserSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//

import SwiftUI

struct UserSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Show Avatars", isOn: $shouldShowUserAvatars)
            }
            Section {
                Toggle("Show Banners", isOn: $shouldShowUserHeaders)
            } footer: {
                Text("Show a user's banner on their profile.")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Users")
        .hoistNavigation(dismiss: dismiss)
    }
}
