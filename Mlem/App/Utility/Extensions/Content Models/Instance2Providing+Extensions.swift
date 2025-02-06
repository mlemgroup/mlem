//
//  Instance2Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-03.
//

import MlemMiddleware

extension Instance2Providing {
    func slurRegex() -> Regex<AnyRegexOutput>? {
        do {
            if let regex = slurFilterRegex {
                return try .init(regex)
            }
        } catch {
            handleError(error, silent: true)
        }
        return nil
    }
}
