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
                    NavigationLink("KeychainAccess", value: LicensesSettingsRoute.licenseDocument(keychainAccessLicense))
                    
                    NavigationLink("Nuke", value: LicensesSettingsRoute.licenseDocument(nukeLicense))

                    NavigationLink("Swift Dependencies", value: LicensesSettingsRoute.licenseDocument(swiftDependenciesLicense))

                    NavigationLink("Swift Markdown UI", value: LicensesSettingsRoute.licenseDocument(swiftMarkdownUILIcense))

                    NavigationLink("Awesome Lemmy Instances", value: LicensesSettingsRoute.licenseDocument(awesomeLemmyInstancesLicense))
                }
            }
            .fancyTabScrollCompatible()
        }
        .navigationTitle("Licenses")
        .navigationBarColor()
    }
}
