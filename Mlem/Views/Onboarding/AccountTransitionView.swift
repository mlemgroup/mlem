//
//  AccountTransitionView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation
import SwiftUI

enum TransitionType {
    case switchingAccount(String)
    case goingToOnboarding
    case reauthenticating
}

struct TransitionView: View {
    let transitionType: TransitionType
    @State var accountNameOpacity: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 24) {
            switch transitionType {
            case let .switchingAccount(username):
                Text("Welcome")
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.5)) {
                            accountNameOpacity = 1.0
                        }
                    }
                Text(username)
                    .opacity(accountNameOpacity)
            case .goingToOnboarding:
                Text("Goodbye!")
            case .reauthenticating:
                Text("Authentication Expired")
            }
        }
        .font(.largeTitle)
        .bold()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
