//
//  LinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import SwiftUI

struct LinkSettingsView: View {
    @AppStorage("links.openInBrowser") var openLinksInBrowser = false
    @AppStorage("links.readerMode") var openLinksInReaderMode = false
    
    var body: some View {
        Form {
            Section("Open External Links") {
                Picker("Open External Links", selection: $openLinksInBrowser) {
                    Text("In-App").tag(false)
                    Text("In Default Browser").tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section {
                Toggle("Open in Reader", isOn: $openLinksInReaderMode)
                    .disabled(openLinksInBrowser)
            } footer: {
                Text("Automatically enable Reader for supported webpages. You can only enable this when using the in-app browser.")
            }
        }
        .navigationTitle("Links")
    }
}
