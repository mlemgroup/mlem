//
//  User.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI

struct User: Codable, Identifiable
{
    let id: Int

    let name: String
    let displayName: String?
    
    let avatarLink: URL?
    let bannerLink: URL?
    let inboxLink: URL?
    
    let bio: String?
    
    let banned: Bool
    
    let actorID: URL
    
    let local: Bool
    let deleted: Bool
    let admin: Bool
    
    let bot: Bool
    
    let onInstanceID: Int
}
