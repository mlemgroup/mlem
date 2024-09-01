//
//  ThemeLabel.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct ThemeLabel: View {
    var title: LocalizedStringResource
    var color1: Color
    var color2: Color?
    var outlineColor: Color = .secondary
    
    var body: some View {
        Label {
            Text(title)
        } icon: {
            if let color2 {
                color1
                    .frame(width: Constants.main.settingsIconSize, height: Constants.main.settingsIconSize)
                    .overlay { ThemeTriangle().fill(color2) }
                    .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                            .stroke(outlineColor, lineWidth: 1)
                    }
                
            } else {
                color1
                    .frame(width: Constants.main.settingsIconSize, height: Constants.main.settingsIconSize)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                            .stroke(outlineColor, lineWidth: 1)
                    }
            }
        }
    }
}

extension ThemeLabel {
    init(title: LocalizedStringResource? = nil, palette: PaletteOption) {
        self.init(title: title ?? palette.label, color1: palette.palette.accent, color2: palette.palette.background)
    }
}

private struct ThemeTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}
