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
    @AppStorage("communityIconShape") var communityIconShape: IconShape = .circle
    
    var body: some View {
        Form {
            Section {
                Toggle("Show Avatars", isOn: $shouldShowCommunityIcons)
                if shouldShowCommunityIcons {
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
            .animation(.default, value: shouldShowCommunityIcons)
            Section {
                Toggle("Show Banners", isOn: $shouldShowCommunityHeaders)
            } footer: {
                Text("The community banner is shown in the community sidebar menu.")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Communities")
        .navigationBarColor()
    }
}
