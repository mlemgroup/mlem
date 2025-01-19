//
//  ConditionalIconLabelStyle.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-19.
//

import SwiftUI

struct ConditionalIconLabelStyle: LabelStyle {
    @Environment(Palette.self) var palette
    
    @Setting(\.showSettingsIcons) var showSettingsIcons
    
    func makeBody(configuration: Configuration) -> some View {
        if showSettingsIcons {
            HStack {
                configuration.icon.foregroundStyle(palette.accent)
                configuration.title
            }
        } else {
            Label(configuration)
                .labelStyle(.titleOnly)
        }
    }
}
