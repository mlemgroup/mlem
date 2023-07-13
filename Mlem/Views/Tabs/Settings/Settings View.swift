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

                #if !os(macOS) && !targetEnvironment(macCatalyst)
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
                #endif

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
                        About()
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
