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
                    NavigationLink("Alert Toast") {
                        ScrollView {
                            MarkdownView(text: alertToastLicense.body, isNsfw: false)
                                .padding()
                        }
                    }
                    
                    NavigationLink("Debounced OnChange") {
                        ScrollView {
                            MarkdownView(text: debouncedOnChangeLicense.body, isNsfw: false)
                                .padding()
                        }
                    }
                    
                    NavigationLink("KeychainAccess") {
                        ScrollView {
                            MarkdownView(text: keychainAccessLicense.body, isNsfw: false)
                                .padding()
                        }
                    }
                    
                    NavigationLink("Nuke") {
                        ScrollView {
                            MarkdownView(text: nukeLicense.body, isNsfw: false)
                                .padding()
                        }
                    }
                    
                    NavigationLink("Swift Markdown UI") {
                        ScrollView {
                            MarkdownView(text: swiftMarkdownUILIcense.body, isNsfw: false)
                                .padding()
                        }
                    }
                    
                    NavigationLink("SwiftUI Cached Async Image") {
                        ScrollView {
                            MarkdownView(text: swiftUICachedAsyncImageLicense.body, isNsfw: false)
                                .padding()
                        }
                    }
                    
                }
            }
        }
        .navigationTitle("Licenses")
    }
}
