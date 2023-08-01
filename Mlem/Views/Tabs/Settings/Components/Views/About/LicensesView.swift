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
                    NavigationLink("Debounced OnChange") {
                        DocumentView(text: debouncedOnChangeLicense.body)
                    }
                    
                    NavigationLink("KeychainAccess") {
                        DocumentView(text: keychainAccessLicense.body)
                    }
                    
                    NavigationLink("Nuke") {
                        DocumentView(text: nukeLicense.body)
                    }
                    
                    NavigationLink("Swift Dependencies") {
                        DocumentView(text: swiftDependenciesLicense.body)
                    }
                    
                    NavigationLink("Swift Markdown UI") {
                        DocumentView(text: swiftMarkdownUILIcense.body)
                    }
                    
                    NavigationLink("SwiftUI Cached Async Image") {
                        DocumentView(text: swiftUICachedAsyncImageLicense.body)
                    }
                    
                }
            }
            .fancyTabScrollCompatible()
        }
        .navigationTitle("Licenses")
    }
}
