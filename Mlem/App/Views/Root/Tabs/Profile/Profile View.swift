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
    
    var markdown: String {
        // swiftlint:disable:next line_length
        "# One\nLorem Ipsum [Link1](https://google.com)\n::: spoiler Spoiler *title*!\n> Quote!\n\nCulpa nisi labore adipisicing ~tempor elit ut commodo~ magna mollit voluptate adipisicing magna. Irure aute deserunt *sit [Link2](https://google.com) voluptate eiusmod*. Sint sint do proident eiusmod dolore `qui est et dolor` dolor cillum dolor do. **Dolor tempor cillum** occaecat aliqua nisi sunt sunt ^dolor^ adipisicing. Excepteur sint ex dolore Lorem sunt nostrud dolor aliqua aute esse incididunt cupidatat. ~~Occaecat eu incididunt~~ commodo irure eiusmod et incididunt anim cillum qui ad nisi.\n:::\ndolor sit amet\n\n---\n>Hello world\n\n![](https://lemmy.ml/pictrs/image/ed5f5ff0-0c0f-428e-a4e7-bb488e77fdaf.png?format=webp)\n\n- **Bold**\n- *Italic*\n- ***Bold and Italic***\n\n4) Image ![](https://lemmy.ml/pictrs/image/ed5f5ff0-0c0f-428e-a4e7-bb488e77fdaf.png?format=webp)\n5) ~~strikethrough~~\n6) `code`\n7) SUPER^SCRIPT^\n8) SUB~SCRIPT~\n9) [Link3](https://google.com)\n```\nfor i in range(5): # This is a super long comment which you need to scroll for\n    print(i)\n```\n"
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
                Markdown(markdown)
                    .padding()
                Divider()
            }
        }
        .fancyTabScrollCompatible()
    }
}
