//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Settings_View: View
{
    
    @State private var contributors: [Contributor] = [
        Contributor(name: "Stuart A. Malone", avatarLink: URL(string: "https://media.mstdn.social/cache/accounts/avatars/109/299/685/376/110/779/original/9ef1f88eff2118a4.png")!, reasonForAcknowledgement: "Came up with a performant and resilient way of getting data from the Lemmy API", websiteLink: URL(string: "https://elk.zone/mstdn.social/@samalone@twit.social")!)
    ]
    
    var body: some View
    {
        NavigationView
        {
            List
            {
                Section(header: Text("Communities"))
                {
                    Settings_Item(
                        settingPictureSystemName: "person.2.circle.fill",
                        settingPictureColor: .blue,
                        settingName: "Fast-Switch Communities",
                        isTicked: false
                    )
                    Settings_Item(
                        settingPictureSystemName: "lock.square.stack.fill",
                        settingPictureColor: .primary,
                        settingName: "Remember Sorting",
                        isTicked: true
                    )
                    Settings_Item(
                        settingPictureSystemName: "hammer.circle.fill",
                        settingPictureColor: .red,
                        settingName: "Some Other Setting",
                        isTicked: true
                    )
                }
                Section(header: Text("Posts"))
                {
                    Settings_Item(
                        settingPictureSystemName: "lock.square.stack.fill",
                        settingPictureColor: .primary,
                        settingName: "Remember Post Sorting",
                        isTicked: false
                    )
                    Settings_Item(
                        settingPictureSystemName: "chevron.right.circle.fill",
                        settingPictureColor: .yellow,
                        settingName: "A different Setting",
                        isTicked: true
                    )
                }
                
                Section {
                    ForEach(contributors)
                    { contributor in
                        NavigationLink {
                            ContributorsView(contributor: contributor)
                        } label: {
                            Text(contributor.name)
                        }

                    }
                } header: {
                    Text("Acknowledged Contributors")
                }

                
                Section(header: Text("About me"), footer: Text("Made thanks to my perfect Elča ❤️"))
                {
                    NavigationLink("Hello", destination: About_Me())
                    Link("Twitter", destination: URL(string: "https://twitter.com/davidbures")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
