//
//  About.swift
//  Mlem
//
//  Created by Weston Hanners on 7/12/23.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var appState: AppState

    @Binding var navigationPath: NavigationPath

    var body: some View {
        Group {
            List {
                Section {
                    appHeaderView
                        .listRowBackground(Color(.systemGroupedBackground))
                }

                Section {
                    Link(destination: URL(string: "https://mlem.group/")!) {
                        Label("Website", systemImage: "globe").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    .buttonStyle(SettingsButtonStyle())

                    Link(destination: URL(string: "https://lemmy.world/c/mlemapp@lemmy.ml")!) {
                        Label("Official Community", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .green, fontSize: 15))
                    }
                    .buttonStyle(SettingsButtonStyle())

                    Link(destination: URL(string: "https://matrix.to/#/%23mlemappspace:matrix.org")!) {
                        Label("Matrix Room", systemImage: "chart.bar.doc.horizontal").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                    .buttonStyle(SettingsButtonStyle())
                }

                Section {
                    Link(destination: URL(string: "https://github.com/mlemgroup/mlem")!) {
                        Label("Github Repository", image: "logo.github").labelStyle(SquircleLabelStyle(color: .black))
                    }
                    .buttonStyle(SettingsButtonStyle())

                    NavigationLink(value: AboutSettingsRoute.contributors) {
                        Label("Contributors", systemImage: "person.2.fill").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                }

                Section {
                    NavigationLink(value: AboutSettingsRoute.privacyPolicy(privacyPolicy)) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    NavigationLink(value: AboutSettingsRoute.eula(eula)) {
                        Label("EULA", systemImage: "doc.plaintext.fill").labelStyle(SquircleLabelStyle(color: .purple))
                    }
                    NavigationLink(value: AboutSettingsRoute.licenses) {
                        Label("Licenses", systemImage: "doc.fill").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                }
            }
            .fancyTabScrollCompatible()
        }
        .navigationTitle("About")
        .navigationBarColor()
    }

    var versionString: String {
        var result = "n/a"

        if let releaseVersion = Bundle.main.releaseVersionNumber {
            result = releaseVersion
        }

        if let buildVersion = Bundle.main.buildVersionNumber {
            result.append(" (\(buildVersion))")
        }

        return result
    }

    @ViewBuilder
    private var appHeaderView: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            Image("logo")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(20.0)
            Text("Mlem \(versionString)")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
