//
//  View+MarkdownToolbarKeyboardInset.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-07.
//  

import UIKit
import SwiftUI

// The second time the keyboard appears, it removes the keyboard safe area for some reason.
// See #3110.
private struct MarkdownToolbarKeyboardInsetViewModifier: ViewModifier {
    let textViews: [UITextView]
    
    @State var inset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.bottom, inset)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification)) { notification in
                update(notification)
            }
    }
    
    func update(_ notification: Notification) {
        var newInset: CGFloat = 0
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let accessory = textViews.first(where: \.isFirstResponder)?.inputAccessoryView,
           let screen = accessory.window?.screen,
           keyboardFrame.minY < screen.bounds.maxY {
            let accessoryFrame = accessory.convert(accessory.bounds, to: screen.coordinateSpace)
            newInset = max(0, keyboardFrame.minY - accessoryFrame.minY)
        }
        if newInset != inset {
            withAnimation(.easeOut(duration: 0.2)) {
                inset = newInset
            }
        }
    }
}

extension View {
    func markdownToolbarKeyboardInset(_ textViews: [UITextView]) -> some View {
        modifier(MarkdownToolbarKeyboardInsetViewModifier(textViews: textViews))
    }
}
