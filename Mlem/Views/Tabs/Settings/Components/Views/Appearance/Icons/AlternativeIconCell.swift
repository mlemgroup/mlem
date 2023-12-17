//
//  AlternativeIconCell.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import SwiftUI

struct AlternativeIconCell: View {
    let icon: AlternativeIcon
    let setAppIcon: (_ id: String?) async -> Void

    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await setAppIcon(icon.id)
            }
        } label: {
            AlternativeIconLabel(icon: icon)
        }.accessibilityElement(children: .combine)
    }
}

struct AlternativeIconCellPreview: PreviewProvider {
    static var previews: some View {
        AlternativeIconCell(icon: AlternativeIcon(id: nil, name: "Default", author: "Mlem team", selected: true)) { _ in }
    }
}
