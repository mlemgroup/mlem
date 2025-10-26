//
//  Data+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-10-10.
//

import Foundation

extension Data {
    func writeToTempFile(fileName: String) throws -> URL {
        let fileUrl = FileManager.default.temporaryDirectory.appending(path: fileName)
        if FileManager.default.fileExists(atPath: fileUrl.absoluteString) {
            try FileManager.default.removeItem(at: fileUrl)
        }
        try write(to: fileUrl)
        return fileUrl
    }
}
