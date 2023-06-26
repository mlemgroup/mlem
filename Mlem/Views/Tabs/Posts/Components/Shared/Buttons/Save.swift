//
//  Save.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

struct SaveButton: View {
    
    // ==== PARAMETERS ==== //

    let isSaved: Bool
    let size: CGFloat
    let accessibilityContext: String
    
    let save: () -> Void
    
    // ==== COMPUTED ==== //
    
    // this needs to be computed because it changes depending on button state
    var saveButtonText: String { isSaved ? "Unsave \(accessibilityContext)" : "Save \(accessibilityContext)" }
    
    // ==== BODY ==== //
    
    var body: some View {
        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
            .frame(width: size, height: size)
            .foregroundColor(isSaved ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(isSaved ? .saveColor : .clear))
            .onTapGesture { save() }
            .accessibilityLabel(saveButtonText)
            .accessibilityAction(named: saveButtonText) { save() }
    }
}
