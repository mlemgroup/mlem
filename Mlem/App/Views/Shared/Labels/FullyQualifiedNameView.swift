//
//  FullyQualifiedNameView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import SwiftUI

struct FullyQualifiedNameView: View {
    @Environment(Palette.self) var palette
    
    let name: String?
    let instance: String?
    let instanceLocation: InstanceLocation
    
    // scale placeholder capsule height and spacing according to font size
    @ScaledMetric(relativeTo: .footnote) var capsuleHeight: CGFloat = 13
    @ScaledMetric(relativeTo: .footnote) var capsuleSpacing: CGFloat = 5
    
    var body: some View {
        if let name, let instance {
            nameText(name: name) + instanceText(instance: instance)
        } else {
            VStack(alignment: .leading, spacing: capsuleSpacing) {
                Capsule()
                    .fill(LinearGradient(
                        colors: [palette.secondary.opacity(0.7), palette.secondary.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: instanceLocation == .bottom ? 100 : 160, height: capsuleHeight)
                
                if instanceLocation == .bottom {
                    Capsule()
                        .fill(LinearGradient(
                            colors: [palette.tertiary.opacity(0.7), palette.tertiary.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 60, height: capsuleHeight * 0.8)
                        .padding(.vertical, capsuleHeight * 0.2)
                }
            }
        }
    }
    
    func nameText(name: String) -> Text {
        Text(name)
            .bold()
            .font(.footnote)
            .foregroundStyle(palette.secondary)
    }
    
    func instanceText(instance: String) -> Text {
        if instanceLocation != .disabled {
            // prepend a newline if location is bottom, again for easy concatenation
            Text("\(instanceLocation == .bottom ? "\n" : "")@\(instance)")
                .font(.footnote)
                .foregroundStyle(palette.tertiary)
        } else {
            Text("") // return empty Text for easy concatenation
        }
    }
}
