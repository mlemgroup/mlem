//
//  AccountTransitionView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation
import SwiftUI

struct TransitionView: View {
    let account: any Account
    @State var accountNameOpacity: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 24) {
            Text(account is UserAccount ? "Welcome" : "Welcome to")
                .onAppear {
                    withAnimation(.easeIn(duration: 0.5)) {
                        accountNameOpacity = 1.0
                    }
                }
            Text(account.nickname)
                .opacity(accountNameOpacity)
        }
        .font(.largeTitle)
        .bold()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
