//
//  Favorite Community.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

struct FavoriteCommunity: Identifiable
{
    let id: UUID = UUID()
    
    let forAccountID: UUID
    
    let community: Community
}
