//
//  OnboardingModel.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-30.
//

import Foundation
import MlemMiddleware

@Observable
class OnboardingModel {
    enum Page { case recommendInstance, username, email }
    
    var page: Page = .recommendInstance
    
    var instance: Instance?
    var username: String?
    var email: String?
}
