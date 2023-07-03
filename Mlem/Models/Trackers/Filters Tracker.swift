//
//  Filters Tracker.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation

class FiltersTracker: ObservableObject {
    @Published var filteredKeywords: [String] = .init()
    @Published var filteredUsers: [String] = .init()

    init() {
        _filteredUsers = .init(initialValue: [])
        _filteredKeywords = .init(initialValue: FiltersTracker.loadFilters())
    }

    static func loadFilters() -> [String] {
        if FileManager.default.fileExists(atPath: AppConstants.filteredKeywordsFilePath.path) {
//            print("Filtered keywords file exists, will attempt to load blocked keywords")
            do {
                return try decodeFromFile(
                    fromURL: AppConstants.filteredKeywordsFilePath,
                    whatToDecode: .filteredKeywords
                ) as? [String] ?? []
            } catch let savedKeywordsDecodingError {
                print("Failed while decoding saved filtered keywords: \(savedKeywordsDecodingError)")
            }
        } else {
            print("Filtered keywords file does not exist, will try to create it")
            do {
                try createEmptyFile(at: AppConstants.filteredKeywordsFilePath)
            } catch let emptyFileCreationError {
                print("Failed while creating an empty file: \(emptyFileCreationError)")
            }
        }
        return []

    }
}
