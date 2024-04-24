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
        VStack {
            Text("\(appState.myUser?.name ?? "No User")")
            Text("\(appState.api.baseUrl)")
            Divider()
            Toggle("Upvote On Save", isOn: $upvoteOnSave)
                .padding(.horizontal, 50)
            Divider()
            MarkdownView("Text\n**strong**\n*emph*\n***strong-emph***\nn^2^ O~2~\n~~strikethrough~~\n`code`\n[Hello](https://google.com)")
                .padding()
                .multilineTextAlignment(.center)
            Divider()
            MarkdownView("**This is in bold [LINK](https://google.com)^2^**")
                .padding()
        }
    }
}
