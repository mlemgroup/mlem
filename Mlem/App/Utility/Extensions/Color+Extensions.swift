//
//  Color+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-29.
//

import Foundation
import SwiftUI

extension Color {
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
    
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
