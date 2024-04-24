//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Dependencies
import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) var appState
    @AppStorage("upvoteOnSave") var upvoteOnSave = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
        }
    }
    
    var content: some View {
        ScrollView {
            VStack {
                Text("\(appState.myUser?.name ?? "No User")")
                Text("\(appState.api.baseUrl)")
                Divider()
                Toggle("Upvote On Save", isOn: $upvoteOnSave)
                    .padding(.horizontal, 50)
                Divider()
                // swiftlint:disable:next line_length
                MarkdownView("# One\nLorem Ipsum\n::: spoiler Title!\nCulpa nisi labore adipisicing ~tempor elit ut commodo~ magna mollit voluptate adipisicing magna. Irure aute deserunt *sit enim voluptate eiusmod*. Sint sint do proident eiusmod dolore qui est et dolor dolor cillum dolor do. **Dolor tempor cillum** occaecat aliqua nisi sunt sunt ^dolor^ adipisicing. Excepteur sint ex dolore Lorem sunt nostrud dolor aliqua aute esse incididunt cupidatat. ~~Occaecat eu incididunt~~ commodo irure eiusmod et incididunt anim cillum qui ad nisi.\n:::\ndolor sit amet")
                    .padding()
                Divider()
            }
        }
        .fancyTabScrollCompatible()
    }
}
