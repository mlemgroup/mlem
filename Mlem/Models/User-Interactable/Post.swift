//
//  Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation

struct Post: Identifiable {
    let id = UUID()
    
    let link: URL
    let title: String
    
    let type: postTypes
    
    let poster: User
}

enum postTypes {
    case text
    case image
    case website
}
