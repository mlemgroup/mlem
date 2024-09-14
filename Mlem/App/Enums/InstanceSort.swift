//
//  InstanceSort.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2024.
//

import Foundation

enum InstanceSort: CaseIterable {
    case alphabetical, score, users, version
    // TODO: Add "New", "Old", "Active Users"? Requires MlemStats update
    // We could add a _lot_ of sort modes here if we wanted to once we get a HTTP server (https://github.com/mlemgroup/mlem/issues/1313)
    
    var label: LocalizedStringResource {
        switch self {
        case .alphabetical: "Alphabetical"
        case .score: "Score"
        case .users: "Users"
        case .version: "Version"
        }
    }
    
    var systemImage: String {
        switch self {
        case .alphabetical: Icons.alphabeticalSort
        case .score: Icons.scoreSort
        case .users: Icons.usersSort
        case .version: Icons.versionSort
        }
    }
}
