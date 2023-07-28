//
//  Score Style.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation

enum VoteComplexStyle: String, CaseIterable, Identifiable, SettingsOptions {
    case plain

    // TEMPORARILY DISABLED to see if users actually care
//    case standard, symmetric, plain

    var id: Self { self }

    var label: String {
        return self.rawValue.capitalized
    }
}
