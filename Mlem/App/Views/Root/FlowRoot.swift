//
//  FlowRoot.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Dependencies
import SwiftUI

struct FlowRoot: View {
    var body: some View {
        if AppState.main.isOnboarding {
            LandingPage()
        } else {
            ContentView()
        }
    }
}
