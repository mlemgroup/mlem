//
//  CommunitySettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//

import SwiftUI

struct CommunitySettingsView: View {
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    var body: some View {
        Form {
            Toggle("Show Avatars", isOn: $shouldShowCommunityIcons)
            Toggle("Show Banner in sidebar", isOn: $shouldShowCommunityHeaders)
            
            Section("Show Community list in...") {
                
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Communities")
        .navigationBarColor()
    }
}
