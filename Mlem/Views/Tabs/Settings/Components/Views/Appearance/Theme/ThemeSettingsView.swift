//
//  ThemeSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 15/07/2023.
//

import SwiftUI

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

struct ThemeLabel: View {
    var title: String
    var color1: Color
    var color2: Color?
    var outlineColor: Color = .secondary
    
    var body: some View {
        Label {
           Text(title)
        } icon: {
            if color2 != nil {
                color1
                    .frame(width: 28, height: 28)
                    .overlay { ThemeTriangle().fill(color2!) }
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(outlineColor, lineWidth: 1)
                    }
                
            } else {
                color1
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(outlineColor, lineWidth: 1)
                    }
            }
        }
    }
}

struct ThemeSettingsView: View {
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    
    var body: some View {
        List {
            Picker("Appearance", selection: $lightOrDarkMode) {
                ThemeLabel(title: "Light", color1: .white)
                    .tag(UIUserInterfaceStyle.light)
                ThemeLabel(title: "Dark", color1: .black)
                    .tag(UIUserInterfaceStyle.dark)
                ThemeLabel(title: "System", color1: .white, color2: .black)
                    .tag(UIUserInterfaceStyle.unspecified)
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .navigationTitle("Theme")
    }
}
