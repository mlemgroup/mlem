//
//  Alternate Icons.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import RegexBuilder
import SwiftUI

// struct AlternateIcons: View {
struct IconSettingsView: View {
    @State var currentIcon: String? = UIApplication.shared.alternateIconName
    
    let icons: [AlternateIconGroup] = [
        .init(authorName: "Sjmarf", collapsed: false, icons: [
            .init(id: nil, name: "Default"),
            .init(id: "icon.sjmarf.pink", name: "Pink"),
            .init(id: "icon.sjmarf.orange", name: "Orange"),
            .init(id: "icon.sjmarf.green", name: "Green"),
            .init(id: "icon.sjmarf.alien", name: "Alien"),
            .init(id: "icon.sjmarf.silver", name: "Silver"),
            .init(id: "icon.sjmarf.ocean", name: "Ocean"),
            .init(id: "icon.sjmarf.pride", name: "Pride")
        ]),
//
        .init(authorName: "Eric Andrews", collapsed: false, icons: [
            .init(id: "icon.eric.lemmy", name: "Lemmy")
        ])
    ]

    var body: some View {
        FancyScrollView {
            VStack(spacing: 32) {
                ForEach(icons, id: \.authorName) { group in
                    if !group.icons.isEmpty {
                        CollapsibleSection(group.authorName, collapsed: group.collapsed) {
                            LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 4), spacing: 10, content: {
                                ForEach(group.icons) { icon in
                                    AlternateIconCell(
                                        icon: icon,
                                        setAppIcon: setAppIcon,
                                        selected: currentIcon == icon.id
                                    )
                                }
                            })
                            .padding(.vertical, 15)
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("App Icon")
    }

    @MainActor
    func setAppIcon(_ id: String?) async {
        do {
            try await UIApplication.shared.setAlternateIconName(id)
            currentIcon = id
        } catch {
            // do nothing!
        }
    }
}
