//
//  AboutMlemView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import ComponentViews
import SwiftUI
import Theming

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
                    FormChevron { Label("Website", icon: .general.website) }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(ThemedColor.themedColorfulAccent(2).gradient)
                Link(destination: URL(string: "https://lemmy.ml/c/mlemapp")!) {
                    FormChevron { Label("Lemmy Community", icon: .lemmy.community) }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(ThemedColor.themedColorfulAccent(3).gradient)
                Link(destination: URL(string: "https://matrix.to/#/#mlemappspace:matrix.org")!) {
                    FormChevron { Label("Matrix Room", image: "matrix.logo") }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(Color.black.gradient) // not ThemedColor because white tint turns this into white square
                Link(destination: URL(string: "https://github.com/mlemgroup/mlem")!) {
                    FormChevron { Label("GitHub Repository", image: "github.logo") }
                        .foregroundStyle(.themedPrimary)
                }
                .tint(Color.black.gradient) // not ThemedColor because white tint turns this into white square
            }
            Section {
                NavigationLink("Privacy Policy", icon: .settings.privacy, destination: .settings(.document(.privacyPolicy)))
                    .tint(ThemedColor.themedColorfulAccent(2).gradient)
                NavigationLink("EULA", icon: .settings.eula, destination: .settings(.document(.eula)))
                    .tint(ThemedColor.themedColorfulAccent(0).gradient)
                NavigationLink("Licenses", icon: .settings.licence, destination: .settings(.licences))
                    .tint(ThemedColor.themedColorfulAccent(4).gradient)
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
                Image(icon: .general.forward)
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
