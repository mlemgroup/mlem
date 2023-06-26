//
//  Comment Sorting Options.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import Foundation

// lemmy_db_schema::CommentSortType
// TODO this is not accurate to the Lemmy enum, active -> hot, and "old" is missing
enum CommentSortType: String, Codable, CaseIterable, Identifiable
{
    case top, hot, new, old
    
    var id: Self { self }
    
    var description: String
    {
        switch self
        {
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
    
    var imageName: String {
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
