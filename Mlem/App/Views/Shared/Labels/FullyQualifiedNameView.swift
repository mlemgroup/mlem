//
//  FullyQualifiedNameView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum InstanceLocation: String, CaseIterable {
    case disabled
    case trailing
    case bottom
    
    var label: LocalizedStringResource {
        switch self {
        case .disabled: "Disabled"
        case .trailing: "Trailing"
        case .bottom: "Bottom"
        }
    }
}

struct FullyQualifiedNameView: View {
    @Environment(Palette.self) private var palette
    
    // parameters
    let name: String?
    let instance: String?
    let instanceLocation: InstanceLocation
    var prependedText: Text = .init(verbatim: "")
    
    // scale placeholder capsule height and spacing according to font size
    @ScaledMetric(relativeTo: .footnote) var capsuleHeight: CGFloat = 13
    @ScaledMetric(relativeTo: .footnote) var capsuleSpacing: CGFloat = 5
    
    // capsule color gradient configuration
    let gradientBegin: CGFloat = 0.55
    let gradientEnd: CGFloat = 0.45
    
    var body: some View {
        if let name, let instance {
            (prependedText + nameText(name: name) + instanceText(instance: instance))
                .lineLimit(instanceLocation != .bottom ? 1 : nil)
                .font(.footnote)
        } else {
            placeholder
        }
    }
    
    func nameText(name: String) -> Text {
        Text(name)
            .bold()
            .foregroundStyle(palette.secondary)
    }
    
    func instanceText(instance: String) -> Text {
        if instanceLocation != .disabled {
            // prepend a newline if location is bottom for easy concatenation
            Text(verbatim: "\(instanceLocation == .bottom ? "\n" : "")@\(instance)")
                .font(.footnote)
                .foregroundStyle(palette.tertiary)
        } else {
            Text(verbatim: "") // return empty Text for easy concatenation
        }
    }
    
    var placeholder: some View {
        VStack(alignment: .leading, spacing: capsuleSpacing) {
            Capsule()
                .fill(LinearGradient(
                    colors: [palette.secondary.opacity(gradientBegin), palette.secondary.opacity(gradientEnd)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: instanceLocation == .bottom ? 100 : 160, height: capsuleHeight)
            
            if instanceLocation == .bottom {
                Capsule()
                    .fill(LinearGradient(
                        colors: [palette.tertiary.opacity(gradientBegin), palette.tertiary.opacity(gradientEnd)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 60, height: capsuleHeight * 0.8)
                    .padding(.vertical, capsuleHeight * 0.2)
            }
        }
    }
}

extension FullyQualifiedNameView {
    init(_ entity: any CommunityOrPersonStub, instanceLocation: InstanceLocation) {
        self.init(name: entity.name, instance: entity.host ?? "unknown", instanceLocation: instanceLocation)
    }
}
