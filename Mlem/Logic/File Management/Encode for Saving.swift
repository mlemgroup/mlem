//
//  Encode for Saving.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

func encodeForSaving(object: any Codable) throws -> Data {
    try JSONEncoder().encode(object)
}
