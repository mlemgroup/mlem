//
//  OnboardingRoute.swift
//  Mlem
//
//  Created by mormaer on 14/09/2023.
//
//

import Foundation
import Navigation

/// Routes for Onboarding navigation flow.
enum OnboardingRoute: Routable {
    case onboard
    case login(URL?)
}
