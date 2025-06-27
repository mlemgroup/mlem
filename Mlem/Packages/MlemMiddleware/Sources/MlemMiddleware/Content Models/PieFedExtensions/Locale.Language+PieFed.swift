//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

extension Locale.Language {
    init?(_ language: PieFedLanguageView) {
        if let code = language.code {
            self = .init(identifier: code)
        } else {
            return nil
        }
    }
}
