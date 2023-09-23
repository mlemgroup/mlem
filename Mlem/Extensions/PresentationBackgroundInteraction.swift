//
//  PresentationBackgroundInteraction.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-21.
//

import SwiftUI

extension View {
    
    /// No-op prior to iOS 16.4.
    func _presentationBackgroundInteraction(enabledUpThrough detent: PresentationDetent) -> some View {
        if #available(iOS 16.4, *) {
            return self.presentationBackgroundInteraction(.enabled(upThrough: detent))
        } else {
            return self
        }
    }
}
