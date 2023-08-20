//
//  String - Escape Special Characters.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
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
    
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension [String] {
    static var alphabet: Self {
        ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
}
