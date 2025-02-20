//
//  DeveloperSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import Dependencies
import MlemMiddleware
import SwiftUI
import NukeUI

// Strings in this view are intentionally left unlocalized; we shouldn't
// be burdening translators with these when they'll never be used

struct DeveloperSettingsView: View {
    // @Dependency(\.persistenceRepository) var persistenceRepository
    
    // @Setting(\.showFeedWelcomePrompt) var showFeedWelcomePrompt
    // @Setting(\.developerMode) var developerMode
    
    // @AppStorage("status.firstAppearance") var firstAppearance: Bool = true
    
    let url1: URL = .init(string: "https://sh.itjust.works/pictrs/image/df8dd5bb-7b80-4da8-8755-c4b35f9251aa.jpeg")!
    let url2: URL = .init(string: "https://sh.itjust.works/pictrs/image/b1d77c25-6a3b-4202-9c30-6890be014d38.png")!
    
    @State var url: URL?
    
    var body: some View {
        VStack {
            FixedImageView(url: url, size: .init(width: 100, height: 100), fallback: .image, showProgress: true)
            // MediaView(url: url)
            
            Button("change") {
//                if url == url1 {
//                    url = url2
//                } else {
//                    url = url1
//                }
                if url == nil {
                    url = url1
                } else if url == url1 {
                    url = url2
                } else {
                    url = nil
                }
            }
        }
//        Form {
//            Section {
//                FixedImageView(url: url, size: .init(width: 100, height: 100), fallback: .image, showProgress: true)
//                    .id(url)
//                
//                Button("change") {
//                    if url == nil {
//                        url = url1
//                    } else if url == url1 {
//                        url = url2
//                    } else {
//                        url = nil
//                    }
//                }
//            }
//            
//            Section {
//                Toggle(String("Developer Mode"), isOn: $developerMode)
//                NavigationLink(String("Error Log"), destination: .settings(.errorLog))
//            }
//            
//            #if DEBUG
//                Section {
//                    Button(String("Reset Feed Welcome Prompt")) {
//                        showFeedWelcomePrompt = true
//                    }
//                
//                    Button(String("Create Error")) {
//                        handleError(ApiClientError.insufficientPermissions)
//                    }
//                    
//                    Button(String("Create Silent Error")) {
//                        handleError(ApiClientError.noEntityFound, silent: true)
//                    }
//                } header: {
//                    Text(verbatim: "Debug Tools")
//                }
//            #endif
//            Button(String("Reset Settings State")) {
//                do {
//                    try persistenceRepository.deleteAllSystemSettings()
//                    firstAppearance = true
//                } catch {
//                    handleError(error)
//                }
//            }
//        }
//        .navigationTitle("Developer")
    }
}

#Preview(traits: .sampleEnvironment) {
    DeveloperSettingsView()
}
