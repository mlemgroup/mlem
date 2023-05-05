//
//  Settings Item.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import SwiftUI

struct Settings_Item: View
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
