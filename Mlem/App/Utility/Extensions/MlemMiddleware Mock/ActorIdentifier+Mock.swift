//
//  ActorIdentifier+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import MlemMiddleware

private let hosts = [
    "lemm.ee",
    "lemmy.world",
    "sh.itjust.works",
    "sopuli.xyz",
    "programming.dev",
    "lemmy.zip"
]

extension ActorIdentifier {
    static func mockPerson(name: String) -> ActorIdentifier {
        // Poor man's hash - using `hashValue` directly gives a different value each time the program is executed
        let hashValue = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        
        var generator = SeededRandomNumberGenerator(seed: hashValue)
        let value = Int.random(in: 0 ..< hosts.count, using: &generator)
        let host = hosts[value]
        return .init(url: URL(string: "https://\(host)/u/\(name)")!)!
    }
}
