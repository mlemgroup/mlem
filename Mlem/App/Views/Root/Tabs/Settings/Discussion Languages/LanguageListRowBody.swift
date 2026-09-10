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
        VStack(alignment: .leading) {
            Text(language.endonym)
            Text(language.exonym(locale: userLocale))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
