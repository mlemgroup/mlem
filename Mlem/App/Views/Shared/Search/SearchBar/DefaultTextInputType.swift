// This code taken from the open-source SwiftUIX library https://github.com/SwiftUIX/SwiftUIX/blob/cf729fcab44196ed7361293bcad493a0e928fb24/Sources/Intermodular/Helpers/SwiftUI/DefaultTextInputType.swift#L10
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A text-input type where `Self.Label == SwiftUI.Text`.
public protocol DefaultTextInputType {
    init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void,
        onCommit: @escaping () -> Void
    )
    
    init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void
    )
}

// MARK: - Extensions

public extension DefaultTextInputType {
    init(
        _ title: some StringProtocol,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = {}
    ) {
        self.init(
            title,
            text: text,
            onEditingChanged: { isEditing.wrappedValue = $0 },
            onCommit: onCommit
        )
    }
}
