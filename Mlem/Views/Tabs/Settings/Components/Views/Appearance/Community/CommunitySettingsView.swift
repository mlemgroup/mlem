//
//  CommunitySettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//
import SwiftUI
struct CommunitySettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Show Avatars", isOn: $shouldShowCommunityIcons)
            }
            Section {
                Toggle("Show Banners", isOn: $shouldShowCommunityHeaders)
            } footer: {
                Text("The community banner is shown in the community sidebar menu.")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Communities")
        .hoistNavigation(dismiss: dismiss)
    }
}
