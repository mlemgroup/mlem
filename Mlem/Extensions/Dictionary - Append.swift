//
//  Dictionary - Append.swift
//  Mlem
//
//  Created by David Bureš on 05.06.2023.
//

import Foundation

extension Dictionary
{
    mutating func append(_ key: Key, _ value: Value) -> Void
    {
        self.updateValue(value, forKey: key)
    }
}
