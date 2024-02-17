//
//  BanType.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

enum InstanceBanType: Equatable {
    case notBanned
    case permanentlyBanned
    case temporarilyBanned(expires: Date)
}
