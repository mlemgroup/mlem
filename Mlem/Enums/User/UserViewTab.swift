//
//  UserViewTab.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation

enum UserViewTab: String, CaseIterable, Identifiable {
    case overview, comments, posts, saved

    var id: Self { self }
    
    var label: String {
        return self.rawValue.capitalized
    }
    
    var onlyShowInOwnProfile: Bool {
        return self == UserViewTab.saved
    }
}
