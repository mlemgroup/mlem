//
//  Removable.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-31.
//

import Foundation

protocol Removable: Hashable {
    mutating func remove(reason: String?, shouldRemove: Bool) async -> Bool
}
