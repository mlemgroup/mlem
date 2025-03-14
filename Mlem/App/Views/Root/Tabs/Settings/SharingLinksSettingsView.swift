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
                        Label(String(localized: mode.label), systemImage: mode.systemImage)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
        }
        .labelStyle(.conditional)
    }
}

enum LinkSharingMode: String, Codable, CaseIterable {
    case myInstance, originalInstance, askEveryTime
    
    var label: LocalizedStringResource {
        switch self {
        case .myInstance: "My Instance"
        case .originalInstance: "Original Instance"
        case .askEveryTime: "Ask Every Time"
        }
    }
    
    var systemImage: String {
        switch self {
        case .myInstance: Icons.instance
        case .originalInstance: "signature"
        case .askEveryTime: "questionmark.circle"
        }
    }
}
