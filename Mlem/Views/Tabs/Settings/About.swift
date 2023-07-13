//
//  About.swift
//  Mlem
//
//  Created by Weston Hanners on 7/12/23.
//

import SwiftUI

struct DeveloperView: View {
    @State var name: String
    @State var link: String
    @State var color: Color = .blue
    
    var body: some View {
        Link(destination: URL(string: link)!) {
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    Text(link)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .accentColor(color)
    }
}

struct About: View {
    var body: some View {
        Group {
            List {
                Section {
                    DeveloperView(name: "Weston",
                                  link: "https://techhub.social/@weston")
                    DeveloperView(name: "Jake",
                                  link: "https://github.com/JakeShirley")
                    DeveloperView(name: "Eric",
                                  link: "https://github.com/EricBAndrews")
                    DeveloperView(name: "Jonathan",
                                  link: "https://github.com/ShadowJonathan")
                } header: {
                    appHeaderView
                }

                Section("Special Contributions") {
                    DeveloperView(name: "tht7",
                                  link: "https://github.com/tht7",
                                  color: .cyan)
                    DeveloperView(name: "Sjmarf",
                                  link: "https://github.com/Sjmarf",
                                  color: .cyan)
                    DeveloperView(name: "J0hnny007",
                                  link: "https://github.com/J0hnny007",
                                  color: .cyan)
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle("About Mlem")
        .listStyle(.insetGrouped)
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
        VStack(spacing: 15) {
            Spacer()
            HStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                        .frame(height: 128)
                    .clipShape(Circle())
                Spacer()
            }
            Text("mlem \(versionString)")
            Spacer(minLength: 5)
        }
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            About()
        }
    }
}
