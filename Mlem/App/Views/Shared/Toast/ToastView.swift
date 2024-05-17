//
//  ToastView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import SwiftUI

struct ToastView: View {
    let toast: Toast
    var body: some View {
        HStack {
            switch toast {
            case let .basic(title: title, subtitle: subtitle, systemImage: systemImage, color: color):
                Text(title)
            default:
                Text("???")
            }
        }
        .frame(height: 47)
        .frame(minWidth: 150)
        .padding(.horizontal)
        .background(
            Capsule()
                .fill(Palette.main.secondaryBackground)
        )
    }
}
