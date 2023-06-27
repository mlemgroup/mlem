//
//  Score Style.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation

enum VoteComplexStyle: String, CaseIterable, Identifiable, SettingsOptions {
    case standard, symmetric

    var id: Self { self }

    var label: String {
        return self.rawValue.capitalized
    }
}
