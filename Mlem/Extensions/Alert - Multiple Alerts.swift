//
//  Alert - Multiple Alerts.swift
//  Mlem
//
//  Created by David Bureš on 05.06.2023.
//

import Foundation
import SwiftUI

extension View {
    public func alert<Value>(
        using value: Binding<Value?>,
        content: (Value) -> Alert
    ) -> some View {
        let binding = Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { _ in value.wrappedValue = nil }
        )
        return alert(isPresented: binding) {
            content(value.wrappedValue!)
        }
    }
}
