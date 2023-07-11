//
//  Create Empty File.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

internal enum FileCreationError: Error {
    case failedToCreateFile
}

func createEmptyFile(at url: URL) throws {
    try "".write(to: url, atomically: true, encoding: .utf8)
}
