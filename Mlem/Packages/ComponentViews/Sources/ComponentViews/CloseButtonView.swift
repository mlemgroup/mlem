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
    
    var ios18Label: LabelType
    var callback: (() -> Void)?
    
    public init(
        ios18Label: LabelType = .xmark,
        callback: (() -> Void)? = nil
    ) {
        self.ios18Label = ios18Label
        self.callback = callback
    }
    
    public var body: some View {
        if #available(iOS 26, *) {
            Button("Dismiss", systemImage: "xmark", action: submit)
        } else {
            ios18Body
        }
    }
    
    @ViewBuilder
    private var ios18Body: some View {
        switch ios18Label {
        case .cancel:
            Button("Cancel", action: submit)
        case .xmark:
            Button(action: submit) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.themedSecondary, .themedSecondary.opacity(0.2))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
    }
    
    func submit() {
        if let callback {
            callback()
        } else {
            dismiss()
        }
    }
}
