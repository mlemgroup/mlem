//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import SwiftUI

public protocol Action {
    func createLabel(environment: EnvironmentValues) -> ActionLabel
    
    @MainActor
    func execute(environment: EnvironmentValues)
}
