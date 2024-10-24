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
        if let person = appState.firstPerson {
            PersonView(person: .init(person), isProfileTab: true)
        } else if let instance = appState.firstSession.instance {
            InstanceView(instance: instance)
        }
    }
}
