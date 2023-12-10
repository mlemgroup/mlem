//
//  Comment Sorting Options.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import Foundation

// lemmy_db_schema::CommentSortType
// TODO: this is not accurate to the Lemmy enum, "controversial" is missing
enum CommentSortType: String, Codable, CaseIterable, Identifiable {
    case top, hot, new, old
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .new:
            return "New"
        case .top:
            return "Top"
        case .hot:
            return "Hot"
        case .old:
            return "Old"
        }
    }
    
    var iconName: String {
        switch self {
        case .new:
            return "sun.max"
        case .top:
            return "calendar.day.timeline.left"
        case .hot:
            return "flame"
        case .old:
            return "books.vertical"
        }
    }
}

extension CommentSortType: SettingsOptions {
    var label: String {
        rawValue.capitalized
    }
}

extension CommentSortType {
    static func appStorageValue(store: UserDefaults = .standard) -> Self {
        let defaultValue = store.string(forKey: "defaultCommentSorting") ?? ""
        return CommentSortType(rawValue: defaultValue) ?? .top
    }
}
