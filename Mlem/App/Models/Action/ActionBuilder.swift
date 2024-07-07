//
//  ActionGroupBuilder.swift
//  Mlem
//
//  Created by Sjmarf on 07/07/2024.
//

import Foundation

@resultBuilder
struct ActionBuilder {
    static func buildBlock(_ children: [any Action]...) -> [any Action] {
        children.flatMap { $0 }
    }

    static func buildEither(first: [any Action]) -> [any Action] {
        first
    }

    static func buildEither(second: [any Action]) -> [any Action] {
        second
    }
    
    static func buildExpression(_ expression: any Action) -> [any Action] {
        [expression]
    }

    static func buildExpression(_ expression: [any Action]) -> [any Action] {
        expression
    }
    
    static func buildOptional(_ action: [any Action]?) -> [any Action] {
        if let action { return action }
        return []
    }
}
