//
//  Color+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import SwiftUI

public extension Color {
    /// Visibly clear color that SwiftUI still renders
    static var fauxClear: Color { .black.opacity(0.00000000001) }
}
