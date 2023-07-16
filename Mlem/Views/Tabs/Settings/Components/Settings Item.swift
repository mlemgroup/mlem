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

struct SquircleLabelStyle: LabelStyle {
    var color: Color
    var fontSize: CGFloat = 17
    
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}

struct SettingsPickerButton<PickerLabel: View>: View {
    @Binding var isOn: Bool
    
    let label: PickerLabel
    
    init(isOn: Binding<Bool>, @ViewBuilder _ label: () -> PickerLabel) {
            self.label = label()
            _isOn = isOn
        }
    
    var body: some View {
        Button { isOn.toggle() } label: {
            HStack {
                label
                Spacer()
                if isOn {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .transition(.opacity)
                }
            }
            .contentShape(Rectangle())
            .animation(.linear(duration: 0.2), value: isOn)
        }
        .buttonStyle(.plain)
    }
}
