//
//  KeyboardAwarePadding.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-05-27.
//

import Combine
import SwiftUI

// https://stackoverflow.com/a/59098816/17629371
struct KeyboardAwareModifier: ViewModifier {
    let removePaddingOnDismiss: Bool
    
    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map(\.cgRectValue.height),
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) {
                if removePaddingOnDismiss || $0 > 0 {
                    keyboardHeight = $0
                }
            }
    }
}

public extension View {
    func keyboardAwarePadding(removePaddingOnDismiss: Bool = true) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier(removePaddingOnDismiss: removePaddingOnDismiss))
    }
}
