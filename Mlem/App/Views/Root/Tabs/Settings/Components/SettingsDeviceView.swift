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
    var scale: CGFloat
    
    var accentColor: AnyShapeStyle {
        if selected {
            return .init(.tint)
        }
        return .init(palette.neutralAccent)
    }
    
    init(
        selected: Bool = false,
        screenPadding: Bool = true,
        scale: CGFloat = 1.0,
        @ViewBuilder screenContent: @escaping () -> ScreenContent
    ) {
        self.selected = selected
        self.screenPadding = screenPadding
        self.screenContent = screenContent()
        self.scale = scale
    }
    
    var body: some View {
        frameView
            .aspectRatio(aspectRatio, contentMode: .fit)
            .frame(maxWidth: (UIDevice.isPad ? 100 : 40) * scale)
            .compositingGroup()
            .opacity(colorScheme == .dark && !selected ? 0.6 : 1)
    }
    
    var aspectRatio: CGFloat {
        if UIDevice.isPad {
            return 3 / 4
        }
        if UIDevice.frameType == .noNotch {
            return 9 / 16
        }
        return 9 / 19
    }
    
    var frameCornerRadiusScaleFactor: CGFloat {
        if UIDevice.isPad {
            return 1 / 12
        }
        if UIDevice.frameType == .noNotch {
            return 1 / 8
        }
        return 1 / 6
    }
    
    var generalPadding: CGFloat {
        scale * 3
    }
    
    var frameView: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: geometry.size.width * frameCornerRadiusScaleFactor)
                .fill(accentColor.opacity(0.1))
                .strokeBorder(accentColor, lineWidth: 2)
                .overlay(alignment: .top) {
                    if UIDevice.frameType != .noNotch {
                        notchView(geometry: geometry)
                            .padding(.top, 2)
                    }
                }
                .background {
                    let radius = geometry.size.width * frameCornerRadiusScaleFactor - 4
                    Color.clear
                        .background(alignment: .top) {
                            VStack(spacing: generalPadding) {
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
                        .padding(screenPadding ? 2 + generalPadding : 2)
                        .padding(.top, geometry.size.height / 15 - 2)
                }
        }
    }
    
    @ViewBuilder
    func notchView(geometry: GeometryProxy) -> some View {
        if UIDevice.frameType == .dynamicIsland {
            Capsule()
                .fill(accentColor)
                .frame(height: geometry.size.height / 25)
                .padding(.horizontal, geometry.size.width / 2.8)
                .padding(.top, 2 * scale)
        } else {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: geometry.size.width * frameCornerRadiusScaleFactor / 5,
                    bottomTrailing: geometry.size.width * frameCornerRadiusScaleFactor / 5,
                    topTrailing: 0
                )
            )
            .fill(accentColor)
            .frame(height: geometry.size.height / 15 - 2)
            .padding(.horizontal, geometry.size.width / (UIDevice.frameType == .narrowNotch ? 3 : 4))
        }
    }
}
