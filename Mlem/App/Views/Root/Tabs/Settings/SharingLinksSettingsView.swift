//
//  SharingLinksSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-09.
//

import SwiftUI

struct SharingLinksSettingsView: View {
    @Setting(\.linkSharingMode) var linkSharingMode
    
    var body: some View {
        Form {
            Section("Share links using...") {
                Picker("Share links using...", selection: $linkSharingMode) {
                    ForEach(LinkSharingMode.allCases, id: \.self) { mode in
                        Text(mode.label)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
        }
    }
}

enum LinkSharingMode: String, Codable, CaseIterable {
    case myInstance, authorInstance, askEveryTime
    
    var label: LocalizedStringResource {
        switch self {
        case .myInstance: "My Instance"
        case .authorInstance: "Author's Instance"
        case .askEveryTime: "Ask Every Time"
        }
    }
}
