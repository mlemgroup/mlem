//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Settings_View: View
{
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true

    @State private var contributors: [Contributor] = [
        Contributor(name: "Stuart A. Malone", avatarLink: URL(string: "https://media.mstdn.social/cache/accounts/avatars/109/299/685/376/110/779/original/9ef1f88eff2118a4.png")!, reasonForAcknowledgement: "Came up with a performant and resilient way of getting data from the Lemmy API", websiteLink: URL(string: "https://elk.zone/mstdn.social/@samalone@twit.social")!),
    ]

    var body: some View
    {
        NavigationView
        {
            List
            {
                Section("Posts")
                {
                    Settings_Item(
                        settingPictureSystemName: "globe",
                        settingPictureColor: .blue,
                        settingName: "Show Website Icons",
                        isTicked: $shouldShowWebsiteFavicons
                    )
                }

                Section
                {
                    ForEach(contributors)
                    { contributor in
                        NavigationLink
                        {
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
