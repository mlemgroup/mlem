//
//  CloseButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 09/03/2024.
//

import Foundation
import SwiftUI

struct CloseButtonView: View {
    @Environment(\.dismiss) var dismiss
    
    var size: CGFloat = 30
    var callback: (() -> Void)?
    
    var body: some View {
        Button {
            if let callback {
                callback()
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: Icons.closeCircleFill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.secondary, .secondary.opacity(0.2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
    }
}
