//
//  Settings Item.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import SwiftUI

struct Settings_Item: View {
    let settingPictureSystemName: String
    let settingPictureColor: Color
    
    let settingName: String
    
    @State var isTicked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: settingPictureSystemName)
                .foregroundColor(settingPictureColor)
            
            Toggle(settingName, isOn: $isTicked)
        }
    }
}
