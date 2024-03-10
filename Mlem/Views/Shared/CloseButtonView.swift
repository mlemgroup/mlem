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
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 30)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.secondary, .secondary.opacity(0.2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
    }
}
