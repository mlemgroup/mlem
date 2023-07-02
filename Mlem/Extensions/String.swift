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
        return !isEmpty
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
