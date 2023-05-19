//
//  Comment Sorting Options.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import Foundation

enum CommentSortTypes: String, Codable, CaseIterable, Identifiable
{
    case new, top, active

    var id: Self { self }

    var description: String
    {
        switch self
        {
        case .new:
            return "New"
        case .top:
            return "Top"
        case .active:
            return "Active"
        }
    }
}
