//
//  Locale.Language+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-04.
//  

import Foundation

extension Locale.Language {
    var endonym: String {
        let code = self.languageCode?.identifier ?? ""
        let locale = Locale(languageCode: self.languageCode)
        return locale.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    func exonym(locale: Locale) -> String {
        let code = self.languageCode?.identifier ?? ""
        return locale.localizedString(forLanguageCode: code) ?? ""
    }
}
