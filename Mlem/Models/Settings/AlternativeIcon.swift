//
//  AlternativeIcon.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import Foundation

struct AlternativeIconGroup {
    let authorName: String
    let collapsed: Bool
    let icons: [AlternativeIcon]
}

struct AlternativeIcon: Identifiable {
    var id: String?
    let name: String
}
