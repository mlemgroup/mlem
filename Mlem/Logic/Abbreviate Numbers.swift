//
//  Abbreviate Numbers.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Foundation

func abbreviateNumber(_ number: Int) -> String {
    if number >= 1_000_000 {
        return "\(Double(round(Double(number) / 100) / 10))M"
    }
    if number >= 10_000 {
        return "\(Int(round(Double(number) / 1000)))K"
    }
    if number >= 1000 {
        return "\(Double(round(Double(number) / 100) / 10))K"
    }
    return String(number)
}
