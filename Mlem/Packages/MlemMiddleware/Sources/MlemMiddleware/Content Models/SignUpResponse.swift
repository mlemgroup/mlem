//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum SignUpResponse {
    public enum Reason: Hashable {
        case awaitingApproval, awaitingEmailVerification
    }
    
    case canLogIn(token: String)
    case cannotLogIn(reasons: Set<Reason>)
    
    init(from loginResponse: LemmyLoginResponse) {
        if let token = loginResponse.jwt {
            self = .canLogIn(token: token)
        }
        var reasons: Set<Reason> = []
        if loginResponse.registrationCreated {
            reasons.insert(.awaitingApproval)
        }
        if loginResponse.verifyEmailSent {
            reasons.insert(.awaitingEmailVerification)
        }
        if !reasons.isEmpty { assertionFailure() }
        self = .cannotLogIn(reasons: reasons)
    }
}
