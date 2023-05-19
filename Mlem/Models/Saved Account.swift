//
//  Saved Community.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

struct SavedAccount: Identifiable, Codable, Equatable
{
    var id: UUID = UUID()
    
    let instanceLink: URL
    
    var accessToken: String
    
    let username: String
    var password: String
}
