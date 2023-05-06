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
                Section
                {
                    NavigationLink {
                        List
                        {
                            Section("Posts")
                            {
                                SettingsItem(
                                    settingPictureSystemName: "globe",
                                    settingPictureColor: .pink,
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
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "theatermasks.circle.fill")
                                .foregroundColor(.pink)
                            Text("Appearance")
                        }
                    }
                }
                
                Section
                {
                    NavigationLink {
                        VStack(alignment: .center, spacing: 20) {
                            VStack(alignment: .center, spacing: 10) {
                                AsyncImage(url: URL(string: "https://media.mstdn.social/accounts/avatars/108/939/255/808/776/594/original/38b73188943130ee.png")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 200, height: 200, alignment: .center)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 200, height: 200, alignment: .center)
                                }

                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Mlem by")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("David Bureš")
                                        .font(.title)
                                }
                            }
                            .padding()
                            
                            List
                            {
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
                                    Text("Contributors")
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
                            }
                        }
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("About Mlem")
                    }

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
