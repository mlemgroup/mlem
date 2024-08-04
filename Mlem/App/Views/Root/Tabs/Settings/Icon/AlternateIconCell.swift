//
//  AlternateIconCell.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import SwiftUI

struct AlternateIconCell: View {
    let icon: AlternateIcon
    let setAppIcon: (_ id: String?) async -> Void
    let selected: Bool

    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await setAppIcon(icon.id)
            }
        } label: {
            AlternateIconLabel(icon: icon, selected: selected)
        }.accessibilityElement(children: .combine)
    }
}
