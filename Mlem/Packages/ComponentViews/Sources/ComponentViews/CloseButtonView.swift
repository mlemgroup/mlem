//
//  CloseButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 09/03/2024.
//

import Foundation
import SwiftUI
import Theming

public struct CloseButtonView: View {
    @Environment(\.dismiss) var dismiss
    
    var size: CGFloat = 30
    var callback: (() -> Void)?
    
    public init(size: CGFloat = 30, callback: (() -> Void)? = nil) {
        self.size = size
        self.callback = callback
    }
    
    public var body: some View {
        Button {
            if let callback {
                callback()
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.themedSecondary, .themedSecondary.opacity(0.2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
    }
}
