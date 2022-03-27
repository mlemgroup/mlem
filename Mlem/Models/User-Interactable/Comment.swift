//
//  Comment.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation

struct Comment: Identifiable {
    let id = UUID()
    
    let link: URL
    
    let content: String
    let datePosted: Date
    
    let poster: User
}
