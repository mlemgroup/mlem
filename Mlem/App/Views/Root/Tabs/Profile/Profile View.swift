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
                MarkdownView("# One\nLorem Ipsum\n::: spoiler Title!\nCulpa nisi labore adipisicing ~tempor elit ut commodo~ magna mollit voluptate adipisicing magna. Irure aute deserunt *sit enim voluptate eiusmod*. Sint sint do proident eiusmod dolore `qui est et dolor` dolor cillum dolor do. **Dolor tempor cillum** occaecat aliqua nisi sunt sunt ^dolor^ adipisicing. Excepteur sint ex dolore Lorem sunt nostrud dolor aliqua aute esse incididunt cupidatat. ~~Occaecat eu incididunt~~ commodo irure eiusmod et incididunt anim cillum qui ad nisi.\n:::\ndolor sit amet\n\n---\n>Hello world\n- **Bold**\n- *Italic*\n- ***Bold and Italic***\n\n4) Image ![](https://lemmy.ml/pictrs/image/ed5f5ff0-0c0f-428e-a4e7-bb488e77fdaf.png?format=webp)\n5) ~~strikethrough~~\n6) `code`\n```\nOfficia proident tempor sit labore proident dolore ex quis excepteur quis. Qui proident aliquip adipisicing fugiat deserunt aliqua aute sint. Consequat exercitation culpa dolor non consequat. Dolore *consectetur* veniam mollit excepteur elit ut non qui laborum est magna minim anim est. Do ipsum ullamco veniam do ullamco est Lorem qui aliquip ullamco ut sint qui. Adipisicing nostrud nulla sunt sit sint sit id ullamco et aute eiusmod non id sint. Fugiat cillum elit irure magna veniam incididunt fugiat.\n```\n")
                    .padding()
                Divider()
            }
        }
        .fancyTabScrollCompatible()
    }
}
