//
//  Outlined Web Complex Style.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation
import SwiftUI

struct OutlinedWebComplexStyle: GroupBoxStyle {

    var roundedRectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 8, style: .continuous)

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .background(Color.systemBackground)
        .clipShape(roundedRectangle)
        .overlay(
            roundedRectangle
                .stroke(Color(.secondarySystemBackground), lineWidth: 1)
        )
    }
}
