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
    @Environment(NavigationLayer.self) var navigation
    @AppStorage("upvoteOnSave") var upvoteOnSave = false
    
    var body: some View {
        content
            .navigationTitle("Profile")
    }
    
    var markdown: String {
        // swiftlint:disable:next line_length
        "# One\nLorem Ipsum [Link1](https://google.com)\nWorld\n::: spoiler Title!\n> Quote!\n\nCulpa nisi labore adipisicing ~tempor elit ut commodo~ magna mollit voluptate adipisicing magna. Irure aute deserunt *sit [Link2](https://google.com) voluptate eiusmod*. Sint sint do proident eiusmod dolore `qui est et dolor` dolor cillum dolor do. **Dolor tempor cillum** occaecat aliqua nisi sunt sunt ^dolor^ adipisicing. Excepteur sint ex dolore Lorem sunt nostrud dolor aliqua aute esse incididunt cupidatat. ~~Occaecat eu incididunt~~ commodo irure eiusmod et incididunt anim cillum qui ad nisi.\n:::\ndolor sit amet\n| Month        | Savings |\n| ------------ | ------- |\n| January      | $250    |\n| **February** | $80     |\n| March        | $420    |\n---\n>Hello world\n\n![](https://lemmy.ml/pictrs/image/ed5f5ff0-0c0f-428e-a4e7-bb488e77fdaf.png?format=webp)\n\n- **Bold**\n- *Italic*\n- ***Bold and Italic***\n\n4) Image ![](https://lemmy.ml/pictrs/image/ed5f5ff0-0c0f-428e-a4e7-bb488e77fdaf.png?format=webp)\n5) ~~strikethrough~~\n6) `code`\n7) SUPER^SCRIPT^\n8) SUB~SCRIPT~\n9) [Link3](https://google.com)\n```\nfor i in range(5): # This is a super long comment which you need to scroll for\n    print(i)\n```\n"
    }
    
    var content: some View {
        ScrollView {
            VStack {
                Text("\(appState.firstAccount.user?.name ?? "No User")")
                Text("\(appState.firstApi.baseUrl)")
                Text(appState.firstAccount.user?.displayName ?? "...")
                Button("Test") {
                    navigation.openSheet(.profile)
                }
                Divider()
                Toggle("Upvote On Save", isOn: $upvoteOnSave)
                    .padding(.horizontal, 50)
                Divider()
                Markdown(markdown)
                    .padding()
                Divider()
            }
        }
    }
}
