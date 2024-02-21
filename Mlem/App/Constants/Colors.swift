//
//  Color+Colors.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import SwiftUI

enum Colors {
    // This is here to give me dynamic light/dark system colors for view backgrounds
    // Maybe add more colors down the line if needed?
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    // Interaction colors--redundant right now, but this will be nice if we want to change them later
    static let upvoteColor = Color.blue
    static let downvoteColor = Color.red
    static let saveColor = Color.green
}
