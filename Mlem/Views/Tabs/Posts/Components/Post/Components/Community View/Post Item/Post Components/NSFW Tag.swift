//
//  NSFW Tag.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import SwiftUI

struct NSFWTag: View {
    let compact: Bool

    var body: some View {
        Text("NSFW")
            .foregroundColor(.white)
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.red))
            .font((compact ? Font.caption : Font.subheadline).weight(Font.Weight.black))
    }
}

struct NSFWToggle: View {
    let compact: Bool
    @State var isEnabled: Bool = false
    
    var body: some View {
        Text("NSFW")
            .foregroundColor(isEnabled ? .white : .gray.opacity(0.6))
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 4)
                .foregroundColor(isEnabled ? .red : .white))
            .font((compact ? Font.caption : Font.subheadline).weight(Font.Weight.black))
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("NSFW Toggle, \(isEnabled ? "Enabled" : "Disabled")")
            .accessibilityHint("Activate to toggle")
            .onTapGesture {
                isEnabled.toggle()
            }
    }
}
