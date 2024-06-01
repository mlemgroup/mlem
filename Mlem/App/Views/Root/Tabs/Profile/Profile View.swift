//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Dependencies
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        Group {
            if let person = (appState.firstSession as? UserSession)?.person {
                PersonView(person: .init(person))
            }
        }
    }
}
