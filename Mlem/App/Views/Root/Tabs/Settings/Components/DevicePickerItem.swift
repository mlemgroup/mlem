//
//  DevicePickerItem.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-21.
//

import SwiftUI

struct DevicePickerItem<Item: Equatable, ScreenContent: View>: View {
    @Environment(Palette.self) var palette
    
    let title: String
    let item: Item
    let scale: CGFloat
    @Binding var selected: Item
    @ViewBuilder var screenContent: () -> ScreenContent
    
    init(
        _ titleKey: String,
        item: Item,
        selected: Binding<Item>,
        scale: CGFloat = 1.0,
        @ViewBuilder screenContent: @escaping () -> ScreenContent
    ) {
        self.title = titleKey
        self.item = item
        self.scale = scale
        self._selected = selected
        self.screenContent = screenContent
    }
    
    var isSelected: Bool { item == selected }
    
    var body: some View {
        VStack {
            SettingsDeviceView(selected: isSelected, scale: scale, screenContent: screenContent)
            Text(title)
                .lineLimit(1)
                .foregroundStyle(isSelected ? palette.selectedInteractionBarItem : palette.primary)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(isSelected ? palette.accent : .clear, in: .capsule)
        }
        .onTapGesture {
            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
            withAnimation(.easeOut(duration: 0.1)) {
                selected = item
            }
        }
        .frame(maxWidth: .infinity)
        .font(.footnote)
    }
}
