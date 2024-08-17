//
//  View+IsAtTopSubscriber.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-14.
//

import Foundation
import SwiftUI

private struct IsAtTopSubscriber: ViewModifier {
    @Binding var isAtTop: Bool
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(IsAtTopPreferenceKey.self, perform: { value in
                isAtTop = value
            })
    }
}

extension View {
    /// Updates a given bool according to the IsAtTopPreferenceKey
    func isAtTopSubscriber(isAtTop: Binding<Bool>) -> some View {
        modifier(IsAtTopSubscriber(isAtTop: isAtTop))
    }
}
