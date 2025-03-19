//
//  TimeInterval+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-19.
//
// Adapted from https://stackoverflow.com/a/30772571

import Foundation

extension TimeInterval {
    var minuteSecondString: String {
        String(format: "%d:%02d", minute, second)
    }
    
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}
