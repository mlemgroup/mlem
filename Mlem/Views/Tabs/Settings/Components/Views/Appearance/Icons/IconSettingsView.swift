//
//  Alternative Icons.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import RegexBuilder
import SwiftUI

// struct AlternativeIcons: View {
struct IconSettingsView: View {
    @State var currentIcon: String? = UIApplication.shared.alternateIconName
    @EnvironmentObject var easterTracker: EasterFlagsTracker
    
    let icons: [AlternativeIconGroup] = [
        .init(authorName: "Sjmarf", collapsed: false, icons: [
            .init(id: nil, name: "Default"),
            .init(id: "icon.sjmarf.pink", name: "Pink"),
            .init(id: "icon.sjmarf.orange", name: "Orange"),
            .init(id: "icon.sjmarf.green", name: "Green"),
            .init(id: "icon.sjmarf.alien", name: "Alien"),
            .init(id: "icon.sjmarf.silver", name: "Silver"),
            .init(id: "icon.sjmarf.ocean", name: "Ocean")
        ]),
        
        .init(authorName: "Eric Andrews", collapsed: false, icons: [
            .init(id: "icon.eric.lemmy", name: "Lemmy")
        ]),
        
        .init(authorName: "Aaron Schneider", collapsed: false, icons: [
            .init(id: "icon.aaron.beehaw", name: "Beehaw")
        ]),
        
        .init(authorName: "Clay/s", collapsed: true, icons: [
            .init(id: "icon.clays.default", name: "Default"),
            .init(id: "icon.clays.red", name: "Red"),
            .init(id: "icon.clays.lime", name: "Lime"),
            .init(id: "icon.clays.mono", name: "Mono"),
            .init(id: "icon.clays.dark", name: "Dark"),
            .init(id: "icon.clays.dev", name: "Dev"),
            .init(id: "icon.clays.wave", name: "Wave"),
            .init(id: "icon.clays.conductor", name: "Conductor"),
            .init(id: "icon.clays.pumpkin", name: "Pumpkin"),
            .init(id: "icon.clays.pride", name: "Pride"),
            .init(id: "icon.clays.pride2", name: "Pride 2"),
            .init(id: "icon.clays.trans", name: "Trans"),
            .init(id: "icon.clays.beehaw", name: "Beehaw")
        ])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ForEach(icons, id: \.authorName) { group in
                    let icons = group.icons.filter { shouldShowIcon(icon: $0) }
                    if !icons.isEmpty {
                        CollapsibleSection(group.authorName, collapsed: group.collapsed) {
                            LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 4), spacing: 10, content: {
                                ForEach(icons) { icon in
                                    AlternativeIconCell(
                                        icon: icon,
                                        setAppIcon: setAppIcon,
                                        selected: UIApplication.shared.alternateIconName == icon.id
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
        .fancyTabScrollCompatible()
        .hoistNavigation()
        .navigationTitle("App Icon")
    }

    static func getCurrentIcon() -> Image {
        let icon = AlternativeIcon(
            id: UIApplication.shared.alternateIconName,
            name: ""
        )
        return AlternativeIconLabel(icon: icon, selected: true).getImage()
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
    
    private func shouldShowIcon(icon: AlternativeIcon) -> Bool {
        if let id = IconId(rawValue: icon.id ?? "Default"),
           let requiredEasterFlag = easterDependentIcons[id] {
            return easterTracker.flags.contains(requiredEasterFlag)
        }
        return true
    }
}

struct AlternativeIconsPreview: PreviewProvider {
    static var previews: some View {
        IconSettingsView()
    }
}
