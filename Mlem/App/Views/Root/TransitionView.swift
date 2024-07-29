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
        let text = text()
        let lines = lines(string: text)
        VStack(alignment: .center, spacing: 24) {
            Text(lines[0])
            if lines.count == 2 {
                Text(lines[1])
                    .opacity(accountNameOpacity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.replacingOccurrences(of: "%@", with: account.nickname))
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                accountNameOpacity = 1.0
            }
        }
        .font(.largeTitle)
        .bold()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 50)
    }
    
    func text() -> String {
        let resource: LocalizedStringResource
        if account is UserAccount {
            resource = .init("Welcome %@", comment: "Example: \"Welcome John\"")
        } else {
            resource = .init("Welcome to %@", comment: "Example: \"Welcome to lemmy.world\"")
        }
        return .init(localized: resource)
    }
    
    // Return type will either be of length 1 or 2
    func lines(string: String) -> [String] {
        if string.hasSuffix(" %@") {
            return [String(string.dropLast(3)), account.nickname]
        }
        if string.hasPrefix("%@ ") {
            return [account.nickname, String(string.dropFirst(3))]
        }
        
        return [string.replacingOccurrences(of: "%@", with: account.nickname)]
    }
}
