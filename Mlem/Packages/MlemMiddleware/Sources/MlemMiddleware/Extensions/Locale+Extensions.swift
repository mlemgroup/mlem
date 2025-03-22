//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-28.
//  

import Foundation

internal extension Locale.Language {
    init?(_ apiLanguage: ApiLanguage) {
        if apiLanguage.code == "und" {
            return nil
        } else {
            self = .init(identifier: apiLanguage.code)
        }
    }
}
