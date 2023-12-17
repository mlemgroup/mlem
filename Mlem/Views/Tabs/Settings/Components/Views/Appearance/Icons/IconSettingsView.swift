//
//  Alternative Icons.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import RegexBuilder
import SwiftUI

let iconName = Reference<Substring>()
let iconAuthor = Reference<Substring>()
let iconFinder = Regex {
    Capture {
        ZeroOrMore(.any, .eager) // Icon name
    }
    " By "
    Capture {
        ZeroOrMore(.any, .eager) // Icon Maker
    }
}
.ignoresCase()

// struct AlternativeIcons: View {
struct IconSettingsView: View {
    @State var currentIcon: String? = UIApplication.shared.alternateIconName
    @EnvironmentObject var easterTracker: EasterFlagsTracker

    var body: some View {
        List {
            iconsList()
        }
        .fancyTabScrollCompatible()
        .hoistNavigation()
        .navigationTitle("App Icon")
    }
    
    @ViewBuilder
    func iconsList() -> some View {
        let allIcons = getAllIcons()
        let creators = allIcons.keys.sorted()
        
        ForEach(creators, id: \.self) { creator in
            if let icons = allIcons[creator], !icons.isEmpty {
                DisclosureGroup {
                    ForEach(icons) { icon in
                        AlternativeIconCell(icon: icon, setAppIcon: setAppIcon)
                    }
                } label: {
                    AlternativeIconLabel(icon: AlternativeIcon(id: icons[0].id, name: creator, author: nil, selected: false))
                }
            }
        }
    }

    func getAllIcons() -> [String: [AlternativeIcon]] {
        guard let iconsBundle = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any?] else { return [:] }

        guard let altIcons = iconsBundle["CFBundleAlternateIcons"] as? [String: Any?] else { return [:] }

        let currentIconSelection = UIApplication.shared.alternateIconName
        
        var ret: [String: [AlternativeIcon]] = .init()
        
        altIcons.keys.forEach { key in
            // parse AlternativeIcon from icon data
            print("found icon: \(key)")
            let match = key.firstMatch(of: iconFinder)
            let name = (match?.output.1 != nil) ? String(match!.output.1) : key
            var author = (match?.output.2 != nil) ? "\(String(match!.output.2))" : "Anonymous"
            author = author.replacingOccurrences(of: "Clays", with: "Clay/s")
            let icon = AlternativeIcon(id: key, name: name, author: author, selected: currentIconSelection == key)
            
            // if we should show this icon, add to map
            if shouldShowIcon(icon: icon) {
                ret[author, default: []].append(icon)
            }
        }
        
        ret.keys.forEach { key in
            ret[key] = ret[key]?.sorted {
                $0.name < $1.name
            }
        }

        return ret
    }

    static func getCurrentIcon() -> Image {
        let icon = AlternativeIcon(
            id: UIApplication.shared.alternateIconName,
            name: "",
            author: "",
            selected: false
        )
        return AlternativeIconLabel(icon: icon).getImage()
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
