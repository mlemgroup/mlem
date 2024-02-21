//
//  UserViewTab.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation

enum UserViewTab: String, CaseIterable, Identifiable {
    case overview, comments, posts, communities

    var id: Self { self }
    
    var label: String {
        rawValue.capitalized
    }
}
