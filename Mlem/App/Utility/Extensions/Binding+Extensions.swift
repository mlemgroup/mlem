//
//  Binding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import SwiftUI

extension Binding where Value == Bool {
    func invert() -> Binding<Bool> {
        .init(
            get: { !wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
