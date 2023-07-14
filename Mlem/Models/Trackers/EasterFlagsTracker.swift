//
//  EasterFlagsTracker.swift
//  Mlem
//
//  Created by tht7 on 13/07/2023.
//

import Foundation
import Combine

@MainActor
class EasterFlagsTracker: ObservableObject {
    @Published var flags: Set<String>
    private var updateObservar: AnyCancellable?
    
    init() {
        _flags = .init(initialValue: EasterFlagsTracker.loadFlags())
        updateObservar = $flags.sink { EasterFlagsTracker.saveFlags($0) }
    }
    
    static func loadFlags() -> Set<String> {
        if FileManager.default.fileExists(atPath: AppConstants.easterFlagsFilePath.path) {
            do {
                return try decodeFromFile(
                    fromURL: AppConstants.easterFlagsFilePath,
                    whatToDecode: .easterFlags
                ) as? Set<String> ?? .init()
            } catch {
                print(String(describing: error))
            }
            // TODO: Hande
        } else {
            // TODO: - AppConstants proper emptyFileCreationError handling
            do {
                try createEmptyFile(at: AppConstants.easterFlagsFilePath)
            } catch {
                // TODO: Hande
            }
        }
        return .init()
    }
    
    static func saveFlags(_ flags: Set<String>) {
        Task(priority: .background) {
            do {
                let encodedEasterFlags: Data = try encodeForSaving(object: flags)
                
                do {
                    try writeDataToFile(data: encodedEasterFlags, fileURL: AppConstants.easterFlagsFilePath)
                } catch let writingError {
                    print("Failed while saving data to file: \(writingError)")
                }
            } catch let encodingError {
                print("Failed while encoding accounts to data: \(encodingError)")
            }
        }
    }
}
