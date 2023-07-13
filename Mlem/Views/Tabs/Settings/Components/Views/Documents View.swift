//
//  Documents View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-09.
//

import Foundation
import SwiftUI

struct DocumentsView: View {
    @State var presentedDocument: Document?
    
    var body: some View {
        VStack(alignment: .labelStart) {
            List {
                Section("Legal") {
                    Button {
                        presentedDocument = privacyPolicy
                    } label: {
                        Label {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "binoculars.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    
                    Button {
                        presentedDocument = eula
                    } label: {
                        Label {
                            Text("EULA")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.plaintext.fill")
                                .foregroundColor(.purple)
                        }
                    }
                }
                
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
                    Button {
                        presentedDocument = alertToastLicense
                    } label: {
                        Label {
                            Text("Alert Toast")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                        }
                    }
                    Button {
                        presentedDocument = debouncedOnChangeLicense
                    } label: {
                        Label {
                            Text("Debounced OnChange")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                        }
                    }
                    Button {
                        presentedDocument = keychainAccessLicense
                    } label: {
                        Label {
                            Text("KeychainAccess")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                        }
                    }
                    Button {
                        presentedDocument = nukeLicense
                    } label: {
                        Label {
                            Text("Nuke")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                        }
                    }
                    Button {
                        presentedDocument = swiftMarkdownUILIcense
                    } label: {
                        Label {
                            Text("Swift Markdown UI")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                        }
                    }
                    Button {
                        presentedDocument = swiftUICachedAsyncImageLicense
                    } label: {
                        Label {
                            Text("SwiftUI Cached Async Image")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
        }
        .sheet(item: $presentedDocument) { presentedDocument in
            documentView(doc: presentedDocument)
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func documentView(doc: Document) -> some View {
        ScrollView {
            MarkdownView(text: doc.body, isNsfw: false)
        }
        .padding()
    }
    
}
