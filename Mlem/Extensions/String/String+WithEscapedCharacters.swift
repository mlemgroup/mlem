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
            let ret = String(data: jsonRepresentation, encoding: .utf8)
            // slightly awkward but preserves contract
            if let ret, !ret.isEmpty { return ret }
            return nil
        } catch {
            return nil
        }
    }
}
