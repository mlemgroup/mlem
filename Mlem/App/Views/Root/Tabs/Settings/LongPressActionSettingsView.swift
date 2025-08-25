//
//  LongPressActionSettingsView.swift
//  Mlem
//
//  Created by Bedir Ekim on 21.05.2025.
//

import SwiftUI

struct LongPressActionSettingsView: View {
    @Setting(\.tab_gestures_longPressAction) private var longPressAction: TabBarLongPressAction
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Long Press Action",
                description: "Choose which action to perform when you tap and hold the profile icon.",
                icon: .settings.longPress
            )
            .tint(.themedColorfulAccent(2))
            
            Section {
                Picker("Long Press Action", selection: $longPressAction) {
                    ForEach(TabBarLongPressAction.allCases, id: \.rawValue) { action in
                        Label(action.label.key, icon: action.icon)
                            .symbolVariant(.circle)
                            .tag(action)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            } footer: {
                Text("Swiping up on the tab bar will always open the account switcher.")
            }
        }
                .labelStyle(.conditional)
        .toggleStyle(.conditional)
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Long Press Action")
    }
}
