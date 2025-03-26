//
//  BanType.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public enum InstanceBanType: Equatable {
    case notBanned
    case permanentlyBanned
    case temporarilyBanned(expires: Date)
    
    var expiryDate: Date? {
        switch self {
        case let .temporarilyBanned(expires): expires
        default: nil
        }
    }
}
