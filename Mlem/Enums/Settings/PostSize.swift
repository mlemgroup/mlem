//
//  Post Sizes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-29.
//

import Foundation

enum PostSize: String {
    case compact, headline, large
}

extension PostSize: SettingsOptions {
    var label: String {
        return self.rawValue.capitalized
    }
    
    var id: Self { self }
}
