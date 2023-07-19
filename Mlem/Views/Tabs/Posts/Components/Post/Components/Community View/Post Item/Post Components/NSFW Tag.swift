//
//  NSFW Tag.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import SwiftUI

struct NSFWTag: View {
    let compact: Bool
    
    init(compact: Bool = false) {
        self.compact = compact
    }

    var body: some View {
        Text("NSFW")
            .dynamicTypeSize(.small ... .accessibility2)
            .foregroundColor(.white)
            .padding(2)
            .background(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                .foregroundColor(.red))
            .font((compact ? Font.caption2 : Font.subheadline).weight(compact ? Font.Weight.heavy : Font.Weight.black))
    }
}

struct NSFWToggle: View {
    let compact: Bool
    @Binding var isEnabled: Bool
    
    var body: some View {
        Text("NSFW")
            .dynamicTypeSize(.small ... .accessibility2)
            .foregroundColor(isEnabled ? .white : .gray.opacity(0.6))
            .padding(2)
            .background(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
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

struct NSFWPreviews: PreviewProvider {
    static var previews: some View {
        NSFWTag(compact: false)
        NSFWTag(compact: true)
        NSFWToggle(compact: true, isEnabled: Binding.constant(true))
        NSFWToggle(compact: true, isEnabled: Binding.constant(false))
        NSFWToggle(compact: false, isEnabled: Binding.constant(true))
        NSFWToggle(compact: false, isEnabled: Binding.constant(false))

    }
}
