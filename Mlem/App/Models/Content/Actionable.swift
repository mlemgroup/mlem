//
//  Actionable.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

protocol Actionable {
    associatedtype ActionKey
    func action(forKey key: ActionKey) -> Action
}
