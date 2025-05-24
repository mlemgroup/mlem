//
//  SignUpPage.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-24.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum SignUpPage: Hashable {
    case recommendInstance
    case enterUsername(instance: Instance3)
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .recommendInstance:
            SignUpRecommendSingleInstanceView()
        case let .enterUsername(instance):
            SignUpUsernameView(instance: instance)
        }
    }
}
