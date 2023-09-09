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
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                
                Section("Open Source Licenses") {
                    NavigationLink("KeychainAccess", value: SettingsRoute.licensesPage(.licenseDocument(keychainAccessLicense)))
                    
                    NavigationLink("Nuke", value: SettingsRoute.licensesPage(.licenseDocument(nukeLicense)))

                    NavigationLink("Swift Dependencies", value: SettingsRoute.licensesPage(.licenseDocument(swiftDependenciesLicense)))

                    NavigationLink("Swift Markdown UI", value: SettingsRoute.licensesPage(.licenseDocument(swiftMarkdownUILIcense)))

                    NavigationLink(
                        "Awesome Lemmy Instances",
                        value: SettingsRoute.licensesPage(.licenseDocument(awesomeLemmyInstancesLicense)))
                }
            }
            .fancyTabScrollCompatible()
        }
        .navigationTitle("Licenses")
        .navigationBarColor()
    }
}
