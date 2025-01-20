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
        Label {
            configuration.title
        } icon: {
            if showSettingsIcons {
                configuration.icon.foregroundStyle(palette.accent)
            }
        }
    }
}

extension LabelStyle where Self == ConditionalIconLabelStyle {
    static var conditional: ConditionalIconLabelStyle { .init() }
}
