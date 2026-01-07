//
//  UnifiedReadFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

class UnifiedReadFilter<FilterTarget: UnifiedReadableProviding>: FilterProviding<FilterTarget> {
    override public func shouldPassFilter(_ item: FilterTarget) -> Bool {
        return !(item.read.value_ ?? false)
    }
}
