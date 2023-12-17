//
//  String+WithEscapedCharacters.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-16.
//

import Foundation

extension String {
    func withEscapedCharacters() -> String? {
        do {
            let jsonRepresentation = try JSONEncoder().encode(self)
            return String(data: jsonRepresentation, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
