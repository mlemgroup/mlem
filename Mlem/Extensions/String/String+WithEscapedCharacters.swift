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
            let ret = String(decoding: jsonRepresentation, as: UTF8.self)
            // slightly awkward but preserves contract
            if !ret.isEmpty { return ret }
            return nil
        } catch {
            return nil
        }
    }
}
