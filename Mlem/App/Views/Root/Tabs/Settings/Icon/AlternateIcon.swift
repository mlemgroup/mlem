//
//  AlternateIcon.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import Foundation

struct AlternateIcon: Identifiable {
    var id: String?
    let name: String
}

struct AlternateIconGroup {
    let authorName: String
    let collapsed: Bool
    let icons: [AlternateIcon]
}
