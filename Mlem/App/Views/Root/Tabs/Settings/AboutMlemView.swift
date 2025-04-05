//
//  AboutMlemView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import ComponentViews
import SwiftUI

struct AboutMlemView: View {
    @Environment(\.palette) var palette
    
    var body: some View {
        Form {
            Section {} header: {
                appHeaderView
                    .listRowBackground(palette.groupedBackground.primary)
                    .foregroundStyle(.themedPrimary)
            }
            .textCase(nil)
            .listRowInsets(.init(top: 50, leading: 0, bottom: 15, trailing: 0))
            Section {
                Link(destination: URL(string: "https://mlem.group")!) {
                    FormChevron { Label("Website", systemImage: Icons.websiteIcon) }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(.themedColorfulAccent(2))
                Link(destination: URL(string: "https://lemmy.ml/c/mlemapp")!) {
                    FormChevron { Label("Lemmy Community", systemImage: Icons.communityFill) }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(.themedColorfulAccent(3))
                Link(destination: URL(string: "https://matrix.to/#/#mlemappspace:matrix.org")!) {
                    FormChevron { Label("Matrix Room", image: "matrix.logo") }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(.black) // non-palette because white tint turns this into white square
                Link(destination: URL(string: "https://github.com/mlemgroup/mlem")!) {
                    FormChevron { Label("GitHub Repository", image: "github.logo") }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(.black) // non-palette because white tint turns this into white square
            }
            Section {
                NavigationLink("Privacy Policy", systemImage: Icons.privacy, destination: .settings(.document(.privacyPolicy)))
                    .tint(.themedColorfulAccent(2))
                NavigationLink("EULA", systemImage: "doc.plaintext.fill", destination: .settings(.document(.eula)))
                    .tint(.themedColorfulAccent(0))
                NavigationLink("Licenses", systemImage: "doc.fill", destination: .settings(.licences))
                    .tint(.themedColorfulAccent(4))
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.squircle)
        .navigationTitle("About Mlem")
    }
    
    @ViewBuilder
    func linkView(_ title: LocalizedStringResource, systemImage: String, destination: String) -> some View {
        Link(destination: URL(string: destination)!) {
            HStack {
                Spacer()
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.themedTertiary)
            }
            .contentShape(.rect)
        }
    }
    
    @ViewBuilder
    var appHeaderView: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            Image("logo")
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(.circle)
            
            Text("Mlem \(versionString)")
                .foregroundStyle(.themedSecondary)
        }
        .frame(maxWidth: .infinity)
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
}
