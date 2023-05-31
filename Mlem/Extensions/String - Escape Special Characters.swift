//
//  String - Escape Special Characters.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import Foundation

extension String
{
    func withEscapedCharacters() -> String
    {
        let jsonRepresentation: Data = try! JSONEncoder().encode(self)
        
        return String(data: jsonRepresentation, encoding: .utf8)!
    }
}
