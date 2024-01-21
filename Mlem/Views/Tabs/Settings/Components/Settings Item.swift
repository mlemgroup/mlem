//
//  Settings Item.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import SwiftUI

struct SwitchableSettingsItem: View {
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = true
    
    let settingPictureSystemName: String
    let settingPictureColor: Color
    let settingName: String

    @Binding var isTicked: Bool
    
    init(
        settingPictureSystemName: String,
        settingPictureColor: Color = .pink,
        settingName: String,
        isTicked: Binding<Bool>
    ) {
        self.settingPictureSystemName = settingPictureSystemName
        self.settingPictureColor = settingPictureColor
        self.settingName = settingName
        
        self._isTicked = isTicked
    }

    var body: some View {
        Toggle(isOn: $isTicked) {
            Label {
                Text(settingName)
            } icon: {
                if showSettingsIcons {
                    Image(systemName: settingPictureSystemName)
                        .foregroundColor(settingPictureColor)
                }
            }
        }
    }
}

struct SelectableSettingsItem<T: SettingsOptions>: View {
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = true
    
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
            Label {
                Text(settingName)
            } icon: {
                if showSettingsIcons {
                    Image(systemName: settingIconSystemName)
                        .foregroundColor(.pink)
                }
            }
        }
    }
}

struct SquircleLabelStyle: LabelStyle {
    var color: Color
    var fontSize: CGFloat = 17
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 16) {
            configuration.icon
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .frame(width: AppConstants.settingsIconSize, height: AppConstants.settingsIconSize)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
                .accessibilityHidden(true)
            configuration.title
        }
    }
}

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }
}

struct CheckboxToggleStyle: ToggleStyle {
   func makeBody(configuration: Configuration) -> some View {
       HStack {
           configuration.label
           Spacer()
           VStack {
               if configuration.isOn {
                   Image(systemName: "checkmark.circle.fill")
                       .foregroundStyle(.white, .blue)
                       .imageScale(.large)
               } else {
                   Image(systemName: "circle")
                       .foregroundStyle(Color(uiColor: .tertiaryLabel))
                       .imageScale(.large)
               }
           }
           .animation(.default, value: configuration.isOn)
       }
       .onTapGesture {
            configuration.isOn.toggle()
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
                    Image(systemName: Icons.success)
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
