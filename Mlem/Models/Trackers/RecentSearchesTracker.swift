//
//  RecentSearchesTracker.swift
//  Mlem
//
//  Created by Jake Shirley on 7/6/23.
//

import Foundation

class RecentSearchesTracker: ObservableObject {
    @Published var recentSearches: [String] = .init()
    
    init() {
        loadFromDisk()
    }
    
    func loadFromDisk() {
        if FileManager.default.fileExists(atPath: AppConstants.recentSearchesFilePath.path) {
            print("Favorite communities file exists, will attempt to load favorite communities")
            do {
                recentSearches = try decodeFromFile(
                    fromURL: AppConstants.recentSearchesFilePath,
                    whatToDecode: .recentSearches
                ) as? [String] ?? []
            } catch let decodingError {
                print("Failed while decoding recent searches, erasing file: \(decodingError)")
            }
        } else {
            print("Recent searches file does not exist, will try to create it")

            do {
                try createEmptyFile(at: AppConstants.recentSearchesFilePath)
            } catch let emptyFileCreationError {
                print("Failed while creating empty file: \(emptyFileCreationError)")
            }
        }
    }
    
    // Lazy save in the background
    func saveToDisk() {
        Task(priority: .background) { [recentSearches] in
            do {
                let encodedSearches: Data = try encodeForSaving(object: recentSearches)
                
                do {
                    try writeDataToFile(data: encodedSearches, fileURL: AppConstants.recentSearchesFilePath)
                } catch let writingError {
                    print("Failed while saving data to file: \(writingError)")
                    clearRecentSearches()
                }
            } catch let encodingError {
                print("Failed while encoding recent searches to data: \(encodingError)")
            }
        }
    }
    
    func addRecentSearch(_ searchText: String) {
        // don't insert duplicates
        guard !recentSearches.contains(searchText) else {
            return
        }
        
        recentSearches.insert(searchText, at: 0)
        
        // Limit results to 5
        while recentSearches.count > 5 {
            recentSearches.remove(at: 5)
        }
        
        saveToDisk()
    }
    
    func clearRecentSearches() {
        recentSearches = []
        saveToDisk()
    }
}
