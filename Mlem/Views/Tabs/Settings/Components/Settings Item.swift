////
////  Settings Item.swift
////  Mlem
////
////  Created by David Bureš on 26.03.2022.
////
//
//import SwiftUI
//
//struct SettingsItem: View
//{
//    @State var settingPictureSystemName: String
//    @State var settingPictureColor: Color
//
//    @State var settingName: String
//
//    @Binding var isTicked: Bool
//
//    var body: some View
//    {
//        HStack
//        {
//            Image(systemName: settingPictureSystemName)
//                .foregroundColor(settingPictureColor)
//
//            Toggle(settingName, isOn: $isTicked)
//        }
//    }
//}

//
//  Settings Item.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import SwiftUI

struct SwitchableSettingsItem: View
{
    @State var settingPictureSystemName: String
    @State var settingPictureColor: Color

    @State var settingName: String

    @Binding var isTicked: Bool

    var body: some View
    {
        HStack
        {
            Image(systemName: settingPictureSystemName)
                .foregroundColor(settingPictureColor)

            Toggle(settingName, isOn: $isTicked)
        }
    }
}

struct SelectableSettingsItem<T: SettingsOptions>: View
{
    @State var settingPictureSystemName: String
    @State var settingPictureColor: Color

    @State var settingName: String

    @Binding var currentValue: T?
    @State var options: [T]

    var body: some View
    {
        NavigationLink {
            List(options, selection: $currentValue) { option in
                HStack {
                    Text(option.label)
                    if option == currentValue {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack
            {
                Image(systemName: settingPictureSystemName)
                    .foregroundColor(settingPictureColor)

                Text(settingName)
                Spacer()
                Text(currentValue?.label ?? "-")
                    .foregroundColor(.secondary)
            }
        }
    }
}
