//
//  AccountSortMode.swift
//  Mlem
//
//  Created by Sjmarf on 23/12/2023.
//

import SwiftUI

enum AccountSortMode: String, CaseIterable, Codable {
    case custom, name, instance, mostRecent
    
    var label: String {
        switch self {
        case .name:
            return "Name"
        case .instance:
            return "Instance"
        case .mostRecent:
            return "Most Recent"
        case .custom:
            return "Custom Order"
        }
    }
    
    var systemImage: String {
        switch self {
        case .name:
            return "textformat"
        case .instance:
            return "at"
        case .mostRecent:
            return "clock"
        case .custom:
            return "line.3.horizontal.decrease"
        }
    }
}
