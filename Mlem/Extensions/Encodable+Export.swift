//
//  Encodable+Export.swift
//  Mlem
//
//  Created by mormaer on 01/08/2023.
//
//

import Foundation

extension Encodable {
    /// A method to create an exportable representation (JSON) of this object and share it
    /// - Parameters:
    ///   - filename: An optional name to use for the exported file, if none is supplied a unique UUID will be used
    ///   - fileManager: The `FileManager` to use when creating the temporary file
    /// - Returns: A `URL` representing the location of the temporary `.json` file
    func export(filename: String = UUID().uuidString, fileManager: FileManager = .default) throws {
        let data = try JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted
        )
        
        let temporaryLocation = fileManager.temporaryDirectory.appendingPathComponent(filename, conformingTo: .json)
        try data.write(to: temporaryLocation)
        
        showShareSheet(URLtoShare: temporaryLocation) { _, _, _, _ in
            // TODO: when we're not calling out to a global function
            // for sharing we should consider handling any errors we see
            // from the above closure argument ^ or the following `try`
            try? fileManager.removeItem(at: temporaryLocation)
        }
    }
}
