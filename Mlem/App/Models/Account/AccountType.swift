//
//  AccountType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-10-17.
//

enum AccountType: String, Codable, Comparable {
    case guest, user, moderator, admin
    
    private var tier: Int {
        switch self {
        case .guest: 0
        case .user: 1
        case .moderator: 2
        case .admin: 3
        }
    }
    
    static func < (lhs: AccountType, rhs: AccountType) -> Bool {
        lhs.tier < rhs.tier
    }
}
