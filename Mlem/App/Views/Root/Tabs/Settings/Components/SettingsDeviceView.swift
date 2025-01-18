//
//  SettingsDeviceView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import SwiftUI

struct SettingsDeviceView<ScreenContent: View>: View {
    @Environment(Palette.self) var palette
    @Environment(\.colorScheme) var colorScheme
    
    var screenContent: ScreenContent
    var selected: Bool
    var screenPadding: Bool
    
    var accentColor: AnyShapeStyle {
        if selected {
            return .init(.tint)
        }
        return .init(palette.neutralAccent)
    }
    
    init(
        selected: Bool = false,
        screenPadding: Bool = true,
        @ViewBuilder screenContent: @escaping () -> ScreenContent
    ) {
        self.selected = selected
        self.screenPadding = screenPadding
        self.screenContent = screenContent()
    }
    
    var body: some View {
        frameView
            .aspectRatio(9 / 19, contentMode: .fit)
            .frame(width: 40)
            .compositingGroup()
            .opacity(colorScheme == .dark && !selected ? 0.6 : 1)
    }
    
    var frameView: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: geometry.size.width / 6)
                .fill(accentColor.opacity(0.1))
                .strokeBorder(accentColor, lineWidth: 2)
                .overlay(alignment: .top) {
                    notchView(geometry: geometry)
                        .padding(.top, 2)
                        .padding(.horizontal, geometry.size.width / 4)
                }
                .background {
                    let radius = geometry.size.width / 6 - 4
                    Color.clear
                        .background(alignment: .top) {
                            VStack {
                                screenContent
                                    .foregroundStyle(accentColor)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .clipShape(.rect(cornerRadius: radius))
                        .mask {
                            LinearGradient(
                                colors: .init(repeating: .black, count: 8) + [
                                    .black.opacity(0.9), .black.opacity(0.7), .black.opacity(0.5)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        }
                        .padding(screenPadding ? 5 : 2)
                        .padding(.top, geometry.size.height / 15 - 2)
                }
        }
    }
    
    @ViewBuilder
    func notchView(geometry: GeometryProxy) -> some View {
        UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: 0, bottomLeading: 1, bottomTrailing: 1, topTrailing: 0)
        )
        .fill(accentColor)
        .frame(height: geometry.size.height / 15 - 2)
    }
}
