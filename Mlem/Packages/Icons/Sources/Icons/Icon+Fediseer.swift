//
//  Icon+Fediseer.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-08.
//

import Foundation

public extension Icon {
    struct FediseerIcons {
        public let fediseer: Icon = .init("shield.checkered")
        public let guarantee: Icon = .init("checkmark.seal")
        public let unguarantee: Icon = .init("xmark.seal")
        public let endorsement: Icon = .init("signature")
        public let hesitation: Icon = .init("exclamationmark.triangle")
        public let censure: Icon = .init("exclamationmark.octagon")
    }
    
    static let fediseer: FediseerIcons = .init()
}
