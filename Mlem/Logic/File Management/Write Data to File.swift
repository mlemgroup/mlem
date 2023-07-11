//
//  Write Data to File.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

func writeDataToFile(data: Data, fileURL: URL) throws {
    try data.write(to: fileURL, options: .atomic)
}
