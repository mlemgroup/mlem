//
//  LanguageListRowBody.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-01.
//

import SwiftUI

struct LanguageListRowBody: View {
    @Environment(\.locale) private var userLocale
    
    let language: Locale.Language
    
    var body: some View {
        let code = language.languageCode?.identifier ?? ""
        let locale = Locale(languageCode: language.languageCode)
        VStack(alignment: .leading) {
            Text(locale.localizedString(forLanguageCode: code)?.capitalized ?? "")
            Text(userLocale.localizedString(forLanguageCode: code) ?? "")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
