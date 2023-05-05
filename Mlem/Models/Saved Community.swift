//
//  Saved Community.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

struct SavedCommunity: Identifiable, Codable, Equatable
{
    var id: UUID = UUID()
    
    let instanceLink: String
    let communityName: String
}
