//
//  ReadFilter.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

class ReadFilter<FilterTarget: ReadableProviding>: FilterProviding<FilterTarget> {
    override public func shouldPassFilter(_ item: FilterTarget) -> Bool {
        return !item.read
    }
}
