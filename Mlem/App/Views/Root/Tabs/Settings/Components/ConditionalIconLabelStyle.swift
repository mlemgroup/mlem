//
//  ConditionalIconLabelStyle.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-19.
//

import SwiftUI

struct ConditionalIconLabelStyle: LabelStyle {
    @Setting(\.a11y_showSettingsIcons) var showSettingsIcons
    
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if showSettingsIcons {
                configuration.icon.foregroundStyle(.themedAccent)
            }
        }
    }
}

extension LabelStyle where Self == ConditionalIconLabelStyle {
    static var conditional: ConditionalIconLabelStyle { .init() }
}
