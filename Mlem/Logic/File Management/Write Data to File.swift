//
//  Write Data to File.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

internal enum FileWritingError: Error {
    case failedToSaveToFile
}

func writeDataToFile(data: Data, fileURL: URL) throws {
    do {
        try data.write(to: fileURL, options: .atomic)
    } catch let fileWritingError {
        print("Failed while saving data to file: \(fileWritingError.localizedDescription)")
        throw FileWritingError.failedToSaveToFile
    }
}
