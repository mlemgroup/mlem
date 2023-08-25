//
//  Int.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Foundation

extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1_000_000
        if million >= 1.0 {
            return "\(round(million * 10) / 10)m"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10) / 10)k"
        } else {
            return description
        }
    }
}
