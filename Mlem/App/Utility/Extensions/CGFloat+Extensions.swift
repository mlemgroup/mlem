//
//  CGFloat+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-17.
//

import Foundation

extension CGFloat {
    func bounded(lower: CGFloat, upper: CGFloat) -> CGFloat {
        if self < lower {
            return lower
        }
        if self > upper {
            return upper
        }
        return self
    }
}
