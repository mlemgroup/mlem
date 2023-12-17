//
//  String+Trimmed.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-16.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
