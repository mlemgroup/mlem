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
                    .buttonStyle(.plain)
                    
                    Button {
                        Task {
                            do {
                                let request = GetCommunityRequest(account: appState.currentActiveAccount, communityId: 346)
                                let community = try await APIClient().perform(request: request).communityView
                                $navigationPath.wrappedValue.append(community)
                            } catch {
                                print("Couldn't load Mlem community")
                            }
                        }
                        
                    } label: {
                        Label("Official Community", systemImage: "house.fill").labelStyle(SquircleLabelStyle(color: .green, fontSize: 15))
                    }
                    .buttonStyle(.plain)
                    
                    Link(destination: URL(string: "https://matrix.to/#/%23mlemapp:matrix.org")!) {
                        Label("Matrix Room", systemImage: "chart.bar.doc.horizontal").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                    .buttonStyle(.plain)
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/mlemgroup/mlem")!) {
                        Label("Github Repository", image: "logo.github").labelStyle(SquircleLabelStyle(color: .black))
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        ContributorsView()
                    } label: {
                        Label("Contributors", systemImage: "person.2.fill").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                }
                
                Section {
                    NavigationLink {
                        ScrollView {
                            MarkdownView(text: privacyPolicy.body, isNsfw: false)
                                .padding()
                        }
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    NavigationLink {
                        ScrollView {
                            MarkdownView(text: eula.body, isNsfw: false)
                                .padding()
                        }
                    } label: {
                        Label("EULA", systemImage: "doc.plaintext.fill").labelStyle(SquircleLabelStyle(color: .purple))
                    }
                    NavigationLink {
                        LicensesView()
                    } label: {
                        Label("Licenses", systemImage: "doc.fill").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                }
            }
        }
        .handleLemmyViews()
        .navigationTitle("About")
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
        VStack(spacing: 10) {
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
