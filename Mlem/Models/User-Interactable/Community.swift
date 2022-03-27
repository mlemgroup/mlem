//
//  Community.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Foundation

struct Community: Identifiable {
    let id = UUID()
    
    let link: URL
    let name: String
    
    let numberOfMembers: Int
}
