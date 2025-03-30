//
//  FederationStatus.swift
//
//
//  Created by Sjmarf on 10/06/2024.
//

import Foundation

public enum FederationStatus {
    case explicitlyAllowed, explicitlyBlocked, implicitlyAllowed, implicitlyBlocked
    
    public var isExplicit: Bool {
        self == .explicitlyAllowed || self == .explicitlyBlocked
    }
    
    public var isAllowed: Bool {
        self == .explicitlyAllowed || self == .implicitlyAllowed
    }
}
