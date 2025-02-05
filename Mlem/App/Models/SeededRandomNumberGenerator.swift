//
//  SeededRandomNumberGenerator.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation

// https://stackoverflow.com/questions/54821659/swift-4-2-seeding-a-random-number-generator
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    init(seed: Int) { srand48(seed) }
    // swiftlint:disable:next legacy_random
    func next() -> UInt64 { UInt64(drand48() * Double(UInt64.max)) }
}
