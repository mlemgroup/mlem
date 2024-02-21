//
//  ContributorsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 15/07/2023.
//

import SwiftUI

struct DeveloperView: View {
    @State var name: String
    @State var link: String
    @State var color: Color = .blue
    
    var body: some View {
        Link(destination: URL(string: link)!) {
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    Text(link)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: Icons.forward)
            }
        }
        .tint(color)
    }
}

struct ContributorsView: View {
    var body: some View {
        List {
            Section("Development Team") {
                DeveloperView(
                    name: "Weston",
                    link: "https://techhub.social/@weston"
                )
                DeveloperView(
                    name: "Jake",
                    link: "https://github.com/JakeShirley"
                )
                DeveloperView(
                    name: "Eric",
                    link: "https://github.com/EricBAndrews"
                )
                DeveloperView(
                    name: "Jonathan",
                    link: "https://github.com/ShadowJonathan"
                )
            }
            
            Section("Special Contributors") {
                DeveloperView(
                    name: "tht7",
                    link: "https://github.com/tht7",
                    color: .cyan
                )
                DeveloperView(
                    name: "Sjmarf",
                    link: "https://github.com/Sjmarf",
                    color: .cyan
                )
                DeveloperView(
                    name: "J0hnny007",
                    link: "https://github.com/J0hnny007",
                    color: .cyan
                )
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Contributors")
        .navigationBarColor()
        .hoistNavigation()
    }
}
