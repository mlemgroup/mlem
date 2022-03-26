//
//  User.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation
import SwiftUI

struct User: Identifiable {
    let id = UUID()
    
    let profilePage: URL
    let name: String
    let avatar: Image
    
    let age: Date
    
    let dateJoined: Date
}
