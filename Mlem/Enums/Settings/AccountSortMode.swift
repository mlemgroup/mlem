//
//  AccountSortMode.swift
//  Mlem
//
//  Created by Sjmarf on 23/12/2023.
//

import SwiftUI

enum AccountSortMode: String, CaseIterable {
    case name, instance, mostRecent
    
    var label: String {
        switch self {
        case .name:
            return "Name"
        case .instance:
            return "Instance"
        case .mostRecent:
            return "Most Recent"
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
        }
    }
}
