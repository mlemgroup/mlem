//
//  ConditionalLabelStyleViewModifier.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-08-25.
//

import SwiftUI
import Icons

private struct ConditionalLabelStyleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .labelStyle(ConditionalIconLabelStyle())
            .toggleStyle(ConditionalIconToggleStyle())
    }
}

extension View {
    func withConditionalLabelStyle() -> some View {
        modifier(ConditionalLabelStyleViewModifier())
    }
}

private struct ConditionalIconToggleStyle: ToggleStyle {
    @Setting(\.a11y_showSettingsIcons) var showSettingsIcons
    
    func makeBody(configuration: Configuration) -> some View {
        Toggle(isOn: Binding(get: { configuration.isOn },
                             set: { configuration.isOn = $0 })) {
            configuration.label
                .labelStyle(ConditionalIconLabelStyle())
        }
    }
}

private struct ConditionalIconLabelStyle: LabelStyle {
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
