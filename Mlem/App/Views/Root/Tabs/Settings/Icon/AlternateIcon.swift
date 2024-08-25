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
    
    init(id: String?, name: LocalizedStringResource) {
        self.id = id
        self.name = String(localized: name)
    }
    
    @_disfavoredOverload
    init(id: String?, name: String) {
        self.id = id
        self.name = name
    }
}

struct AlternateIconGroup {
    let authorName: String
    let collapsed: Bool
    let icons: [AlternateIcon]
}
