//
//  Settings Item.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import SwiftUI

struct SwitchableSettingsItem: View {
    @State var settingPictureSystemName: String
    @State var settingPictureColor: Color

    @State var settingName: String

    @Binding var isTicked: Bool

    var body: some View {
        HStack {
            Image(systemName: settingPictureSystemName)
                .foregroundColor(settingPictureColor)

            Toggle(settingName, isOn: $isTicked)
        }
    }
}

struct SelectableSettingsItem<T: SettingsOptions>: View {
    let settingIconSystemName: String
    let settingName: String
    @Binding var currentValue: T
    let options: [T]

    var body: some View {
        Picker(selection: $currentValue) {
            ForEach(options) { settingsOption in
                HStack {
                    // settingsOption.icon
                    Text(String(settingsOption.label))
                }
            }
        } label: {
            HStack(alignment: .center) {
                Image(systemName: settingIconSystemName)
                    .foregroundColor(.pink)
                Text(settingName)
            }
        }
    }
}
