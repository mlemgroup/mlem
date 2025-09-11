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
    
    public enum LabelType {
        case cancel, xmark
    }
    
    var size: CGFloat = 30
    var ios18Label: LabelType
    var callback: (() -> Void)?
    
    public init(
        size: CGFloat = 30,
        ios18Label: LabelType = .xmark,
        callback: (() -> Void)? = nil
    ) {
        self.size = size
        self.ios18Label = ios18Label
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
            if #available(iOS 26, *) {
                Image(systemName: "xmark")
            } else {
                ios18LabelView
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
    }
    
    @ViewBuilder
    private var ios18LabelView: some View {
        switch ios18Label {
        case .cancel:
            Text("Cancel")
        case .xmark:
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.themedSecondary, .themedSecondary.opacity(0.2))
        }
    }
}
