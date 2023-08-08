//
//  LayoutWidgetTracker.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2023.
//

import Foundation

struct LayoutWidgetGroups: Codable {
    var post: [PostLayoutWidgetType]
    var comment: [PostLayoutWidgetType]
}

class LayoutWidgetTracker: ObservableObject {
    
    @Published var groups: LayoutWidgetGroups?
    
    init() {
        loadFromDisk()
    }
    
    var defaultLayout: LayoutWidgetGroups {
        .init(
            post: [.scoreCounter, .infoStack, .save, .reply],
            comment: [.scoreCounter, .infoStack, .save, .reply]
        )
    }
    
    func loadFromDisk() {
        print(AppConstants.widgetLayoutPath.path)
        if FileManager.default.fileExists(atPath: AppConstants.widgetLayoutPath.path) {
            print("Layout widgets file exists, will attempt to load layout widgets")
            do {
                self.groups = try decodeFromFile(
                    fromURL: AppConstants.widgetLayoutPath,
                    whatToDecode: .layoutWidgets
                ) as? LayoutWidgetGroups ?? defaultLayout
                
            } catch let decodingError {
                print("Failed while decoding layout widgets, erasing file: \(decodingError)")
                do {
                    try FileManager.default.removeItem(at: AppConstants.widgetLayoutPath)
                } catch {
                    print("Failed to erase layout widgets file")
                }
                self.groups = defaultLayout
            }
        } else {
            print("Layout widgets file does not exist, will try to create it")

            do {
                try createEmptyFile(at: AppConstants.widgetLayoutPath)
            } catch let emptyFileCreationError {
                print("Failed while creating empty file: \(emptyFileCreationError)")
            }
            self.groups = defaultLayout
        }
    }
    
    // Lazy save in the background
    func saveToDisk() {
        Task(priority: .background) { [groups] in
            do {
                let encodedSearches: Data = try encodeForSaving(object: groups)
                
                do {
                    try writeDataToFile(data: encodedSearches, fileURL: AppConstants.widgetLayoutPath)
                } catch let writingError {
                    print("Failed while saving data to file: \(writingError)")
                }
            } catch let encodingError {
                print("Failed while encoding recent searches to data: \(encodingError)")
            }
        }
    }
}
