//
//  Removable.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-31.
//

import Foundation

protocol Removable {
    var removalId: Int { get }
    var removed: Bool { get set }
    var purged: Bool { get set }
}
