//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openURL) private var openURL

    @State private var accountToSwitchTo: SavedAccount?
    
    @State private var specialContributors: [Contributor] = [
        Contributor(
            name: "Seb Jachec",
            avatarLink: URL(string: "https://avatars.githubusercontent.com/u/379991?v=4")!,
            reasonForAcknowledgement: """
                                      Implemented many critical features, namely comment rendering, among others. \
                                      Is always great help with any Swift and programming questions, and I would never \
                                      have come this far without his help
                                      """,
            websiteLink: URL(string: "https://github.com/sebj")!
        )
    ]
    @State private var contributors: [Contributor] = [
        Contributor(
            name: "Stuart A. Malone",
            avatarLink: URL(string: "https://media.mstdn.social/cache/accounts/avatars/109/299/685/376/110/779/original/9ef1f88eff2118a4.png")!,
            reasonForAcknowledgement: "Came up with a performant and resilient way of getting data from the Lemmy API",
            websiteLink: URL(string: "https://elk.zone/mstdn.social/@samalone@twit.social")!
        )
    ]

    func getVersionString() -> String {
        var result = "n/a"

        if let releaseVersion = Bundle.main.releaseVersionNumber {
            result = releaseVersion
        }

        if let buildVersion = Bundle.main.buildVersionNumber {
            result.append(" (\(buildVersion))")
        }

        return result
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        GeneralSettingsView()
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "gearshape.circle.fill")
                                .foregroundColor(.gray)
                            Text("General")
                        }
                    }

                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "theatermasks.circle.fill")
                                .foregroundColor(.pink)
                            Text("Appearance")
                        }
                    }
                    NavigationLink {
                        FiltersSettingsView()
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "slash.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Filters")
                        }
                    }
                }

                Section {
                    NavigationLink {
                        AlternativeIcons()
                    } label: {
                        HStack(alignment: .center) {
                            AlternativeIcons.getCurrentIcon()
                                .foregroundColor(.pink)
                            Text("Alternative Icons")
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        AccountsPage(selectedAccount: $accountToSwitchTo)
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "person.fill.questionmark")
                                .foregroundColor(.mint)
                            Text("Switch Account")
                        }
                    }
                }

                Section {
                    NavigationLink {
                        VStack(alignment: .center, spacing: 20) {
                            List {
                                Section {
                                    ForEach(specialContributors) { contributor in
                                        NavigationLink {
                                            ContributorsView(contributor: contributor)
                                        } label: {
                                            Text(contributor.name)
                                        }
                                    }
                                } header: {
                                    Text("Special Contributors")
                                } footer: {
                                    Text("Without Seb's help, none of my apps would exist.")
                                }

                                Section {
                                    ForEach(contributors) { contributor in
                                        NavigationLink {
                                            ContributorsView(contributor: contributor)
                                        } label: {
                                            Text(contributor.name)
                                        }
                                    }
                                } header: {
                                    Text("Contributors")
                                }

                                Section {
                                    Link(destination: URL(string: "https://github.com/lorenzofiamingo/swiftui-cached-async-image")!) {
                                        Text("Cached Async Image")
                                    }
                                    Link(destination: URL(string: "https://github.com/gonzalezreal/swift-markdown-ui")!) {
                                        Text("MarkdownUI")
                                    }
                                } header: {
                                    Text("Packages Used")
                                }

                                Text("Version \(getVersionString())")
                            }
                        }
                    } label: {
                        Label {
                            Text("About Mlem")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }

                    /* Disabled
                    Link(destination: URL(string: "https://lemmy.ml/c/mlemapp")!) {
                        Image(systemName: "person.2.circle.fill")
                            .foregroundColor(.purple)
                        Text("c/mlemapp")
                    }
                    .buttonStyle(.plain)
                     */
                    
                    /* Disabled - Can't seem to get the Matrix link to work with "#" in it
                    Link(destination: URL(string: "https://matrix.to/#/#mlemapp:matrix.org")!) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.black)
                        Text("Mlem Matrix Space")
                    }
                    .buttonStyle(.plain)
                     */
                    
                    Link(destination: URL(string: "https://github.com/mlemgroup/mlem")!) {
                        Label {
                            Text("Mlem GitHub Repository")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "curlybraces.square.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        DocumentsView()
                    } label: {
                        Label {
                            Text("Documents")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "books.vertical.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: accountToSwitchTo) { account in
                guard let account else { return }
                appState.setActiveAccount(account)
            }
        }
    }
}
