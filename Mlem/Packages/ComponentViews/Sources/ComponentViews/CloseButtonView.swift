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
    
    var requiresConfirmation: Bool
    var callback: (() -> Void)?

    @State var showingConfirmation: Bool = false
    
    public init(
        requiresConfirmation: Bool = false,
        callback: (() -> Void)? = nil
    ) {
        self.requiresConfirmation = requiresConfirmation
        self.callback = callback
    }
    
    public var body: some View {
        Button("Dismiss", systemImage: "xmark", action: submit)
            .confirmationDialog("Really close?", isPresented: $showingConfirmation) {
                Button("Yes", role: .destructive, action: submit)
            } message: {
                Text("Really close?")
            }
    }
    
    func submit() {
        if requiresConfirmation, !showingConfirmation {
            showingConfirmation = true
        } else if let callback {
            callback()
        } else {
            dismiss()
        }
    }
}
