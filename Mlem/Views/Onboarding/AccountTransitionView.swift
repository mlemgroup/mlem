//
//  AccountTransitionView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation
import SwiftUI

struct TransitionView: View {
    let accountName: String?
    @State var accountNameOpacity: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 24) {
            if let accountName {
                Text("Welcome")
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.5)) {
                            accountNameOpacity = 1.0
                        }
                    }
                Text(accountName)
                    .opacity(accountNameOpacity)
            } else {
                Text("Goodbye!")
            }
        }
        .font(.largeTitle)
        .bold()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
