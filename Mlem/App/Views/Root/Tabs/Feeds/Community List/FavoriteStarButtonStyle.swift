//
//  FavoriteStarButtonStyle.swift
//  Mlem
//
//  Created by Jake Shirley on 6/19/23.
//

import Dependencies
import SwiftUI

struct FavoriteStarButtonStyle: ButtonStyle {
    let isFavorited: Bool

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: isFavorited ? Icons.favoriteFill : Icons.favorite)
            .foregroundColor(.blue)
            .opacity(isFavorited ? 1.0 : 0.2)
            .accessibilityRepresentation { configuration.label }
    }
}
