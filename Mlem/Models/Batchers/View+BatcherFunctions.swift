//
//  View+BatcherFunctions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-09.
//

import Foundation
import SwiftUI

struct AutoFlushBatchers: ViewModifier {
    let batchers: [any Batcher]
    
    func body(content: Content) -> some View {
        content
            .onDisappear {
                for batcher in batchers {
                    Task {
                        await batcher.flush()
                    }
                }
            }
    }
}

extension View {
    /// Attach to a view to automatically flush all batchers when the view disappears
    func autoFlushBatchers(batchers: [any Batcher]) -> some View {
        modifier(AutoFlushBatchers(batchers: batchers))
    }
}
