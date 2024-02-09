//
//  AboutView.swift
//  Mlem
//
//  Created by Weston Hanners on 7/12/23.
//

import SwiftUI

struct AboutView: View {
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
                        Label("Github Repository", image: "github.logo").labelStyle(SquircleLabelStyle(color: .black))
                    }
                    .buttonStyle(SettingsButtonStyle())

                    NavigationLink(.aboutSettings(.contributors)) {
                        Label("Contributors", systemImage: "person.2.fill").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                }

                Section {
                    NavigationLink(.aboutSettings(.document(privacyPolicy))) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    NavigationLink(.aboutSettings(.document(eula))) {
                        Label("EULA", systemImage: "doc.plaintext.fill").labelStyle(SquircleLabelStyle(color: .purple))
                    }
                    NavigationLink(.aboutSettings(.licenses)) {
                        Label("Licenses", systemImage: "doc.fill").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                }
            }
            .fancyTabScrollCompatible()
        }
        .navigationTitle("About")
        .navigationBarColor()
        .hoistNavigation()
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
            LogoView()
            
            Text("Mlem \(versionString)")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
