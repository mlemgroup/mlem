//
//  SmallOverlayButtonLabel.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-06.
//

import SwiftUI
import Icons

struct SmallOverlayButtonLabel: View {
    let isOn: Bool
    let text: (on: LocalizedStringResource, off: LocalizedStringResource)
    let icons: (on: Icon, off: Icon)
    
    init(isOn: Bool, text: (on: LocalizedStringResource, off: LocalizedStringResource), icons: (on: Icon, off: Icon)) {
        self.isOn = isOn
        self.text = text
        self.icons = icons
    }
    
    init(text: LocalizedStringResource, icon: Icon) {
        self.isOn = true
        self.text = (on: text, off: text)
        self.icons = (on: icon, off: icon)
    }
    
    var body: some View {
        Label {
            Text(isOn ? text.on : text.off)
        } icon: {
            Image(icon: isOn ? icons.on : icons.off)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(5)
                .foregroundStyle(.white)
                .contentShape(.rect)
        }
        .labelStyle(.iconOnly)
    }
}
