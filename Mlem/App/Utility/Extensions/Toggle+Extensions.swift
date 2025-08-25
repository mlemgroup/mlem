//
//  Toggle+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-08-25.
//

import SwiftUI
import Icons

struct ConditionalIconToggeStyle: ToggleStyle {
    @Setting(\.a11y_showSettingsIcons) var showSettingsIcons
    
    func makeBody(configuration: Configuration) -> some View {
        Toggle(isOn: Binding(get: { configuration.isOn },
                             set: { configuration.isOn = $0 })) {
            configuration.label
                .labelStyle(.conditional)
        }
    }
}

extension ToggleStyle where Self == ConditionalIconToggeStyle {
    static var conditional: ConditionalIconToggeStyle { .init() }
}
