//
//  Int+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 13/04/2024.
//

import Foundation

extension Int {
    var abbreviated: String {
        if self >= 10_000_000 {
            return "\(Int(floor(Double(self) / 1_000_000)))M"
        }
        if self >= 1_000_000 {
            return "\(Double(floor(Double(self) / 100_000) / 10))M"
        }
        if self >= 10000 {
            return "\(Int(floor(Double(self) / 1000)))K"
        }
        if self >= 1000 {
            return "\(Double(floor(Double(self) / 100) / 10))K"
        }
        return String(self)
    }
}
