//
//  Documents View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-09.
//

import Foundation
import SwiftUI

struct LicensesView: View {
    var body: some View {
        VStack(alignment: .labelStart) {
            List {
                Section("Licensed Creative Works") {
                    Link(destination: URL(string: "https://creativecommons.org/licenses/by-nc-sa/4.0/")!) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Beehaw Community Icon")
                                Text("by Aaron Schneider CC-BY-NC-SA 4.0")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(systemName: Icons.forward)
                        }
                    }
                }
                
                Section("Open Source Licenses") {
                    NavigationLink("KeychainAccess", value: NavigationRoute.licenseSettings(.licenseDocument(keychainAccessLicense)))
                    
                    NavigationLink("Nuke", value: NavigationRoute.licenseSettings(.licenseDocument(nukeLicense)))

                    NavigationLink("Swift Dependencies", value: NavigationRoute.licenseSettings(.licenseDocument(swiftDependenciesLicense)))

                    NavigationLink("Swift Markdown UI", value: NavigationRoute.licenseSettings(.licenseDocument(swiftMarkdownUILIcense)))

                    NavigationLink(
                        "Awesome Lemmy Instances",
                        value: NavigationRoute.licenseSettings(.licenseDocument(awesomeLemmyInstancesLicense)))
                }
            }
            .fancyTabScrollCompatible()
        }
        .navigationTitle("Licenses")
        .navigationBarColor()
    }
}
