//
//  AppFlow.swift
//  Mlem
//
//  Created by mormaer on 08/09/2023.
//
//

import Foundation

/// An enumeration that describes the types of flow that are supported by the application
enum AppFlow: Equatable {
    /// The onboarding flow
    case onboarding
    /// An 'signed in'' session with the users `SavedAccount` as an associated value
    case account(SavedAccount)
}
