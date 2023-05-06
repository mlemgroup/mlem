//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct SettingsView: View
{
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true

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
                    SettingsItem(
                        settingPictureSystemName: "globe",
                        settingPictureColor: .blue,
                        settingName: "Show website icons",
                        isTicked: $shouldShowWebsiteFavicons
                    )
                }
                
                Section("Icons")
                {
                    SettingsItem(
                        settingPictureSystemName: "person.circle.fill",
                        settingPictureColor: .pink,
                        settingName: "Show user avatars",
                        isTicked: $shouldShowUserAvatars
                    )
                    
                    SettingsItem(
                        settingPictureSystemName: "person.2.circle.fill",
                        settingPictureColor: .pink,
                        settingName: "Show community icons",
                        isTicked: $shouldShowCommunityIcons
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

                Section
                {
                    Link(destination: URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!) {
                        Text("SwiftyJSON")
                    }
                    Link(destination: URL(string: "https://github.com/lorenzofiamingo/swiftui-cached-async-image")!) {
                        Text("Cached Async Image")
                    }
                } header: {
                    Text("Packages Used")
                }

                Section(header: Text("About me"), footer: Text("Made thanks to my perfect Elča ❤️"))
                {
                    NavigationLink("Hello", destination: AboutMe())
                    Link("Twitter", destination: URL(string: "https://twitter.com/davidbures")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
