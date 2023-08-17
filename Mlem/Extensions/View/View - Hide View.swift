//
//  View - Hide View.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
