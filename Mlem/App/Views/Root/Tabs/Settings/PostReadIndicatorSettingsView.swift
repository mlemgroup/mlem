//
//  PostReadIndicatorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-19.
//

import SwiftUI

struct PostReadIndicatorSettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.readPostIndicator) var readPostIndicator
    @Setting(\.readOutlineThickness) var readOutlineThickness
    
    @State var readBarThicknessSlider: Double
    
    init() {
        @Setting(\.readOutlineThickness) var readOutlineThickness
        _readBarThicknessSlider = .init(wrappedValue: Double(readOutlineThickness))
    }

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Read Indicator",
                // swiftlint:disable:next line_length
                description: "When you've read a post already, its title will appear dimmed. If you like, you can choose an additional way of indicating read status."
            ) {
                Image(systemName: Icons.read)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .foregroundStyle(.tertiary)
            }
            Section {
                Toggle(
                    "Additional Read Indicator",
                    isOn: .init(
                        get: { readPostIndicator != .none },
                        set: { readPostIndicator = $0 ? .checkmark : .none }
                    )
                )
            } footer: {
                Text("This is turned on by default because Differentiate Without Color is enabled in System Settings.")
            }
            if readPostIndicator != .none {
                Section {
                    HStack {
                        pickerItem(for: .checkmark)
                        pickerItem(for: .outline)
                    }
                }
            }
            if readPostIndicator == .outline {
                Section {
                    outlineThicknessSlider
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: readPostIndicator)
        .contentMargins(.top, 16)
    }
    
    @ViewBuilder
    var outlineThicknessSlider: some View {
        VStack(alignment: .leading) {
            Text("Outline Thickness")
            
            Slider(
                value: $readBarThicknessSlider,
                in: 1 ... 5,
                step: 1
            ) {
                Text("Outline Thickness")
            } minimumValueLabel: {
                Text(verbatim: "1")
            } maximumValueLabel: {
                Text(verbatim: "5")
            } onEditingChanged: { editing in
                if !editing {
                    readOutlineThickness = Int(readBarThicknessSlider)
                }
            }
        }
    }
    
    @ViewBuilder
    func pickerItem(for style: ReadPostIndicator) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            preview(for: style)
            HStack {
                Text(style.label)
                Checkbox(isOn: style == readPostIndicator)
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
            readPostIndicator = style
        }
    }
    
    @ViewBuilder
    func preview(for style: ReadPostIndicator) -> some View {
        UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 0, topTrailing: 15)
        )
        .fill(palette.secondaryGroupedBackground)
        .stroke(style == .outline ? palette.secondary : .clear, lineWidth: 2)
        .overlay(alignment: .topTrailing) {
            HStack {
                if style == .checkmark {
                    Image(systemName: Icons.success)
                        .foregroundStyle(palette.secondary)
                }
                Image(systemName: Icons.menu)
            }
            .font(.title2)
            .frame(height: 30)
            .padding(.top, 15)
            .padding(.trailing, 20)
        }
        .padding([.top, .trailing], 20)
        .padding([.bottom, .leading], -2)
        .background(palette.groupedBackground)
        .frame(width: 120, height: 80)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(palette.tertiary, lineWidth: 1)
        }
    }
}
