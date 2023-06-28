//
//  Alternative Icons.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import SwiftUI
import RegexBuilder

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

struct AlternativeIcons: View {

    @State var currentIcon: String? = UIApplication.shared.alternateIconName

    var body: some View {
        List {
            ForEach(getAllIcons()) { icon in
                AlternativeIconCell(icon: icon, setAppIcon: setAppIcon)
            }
        }
    }

    func getAllIcons() -> [AlternativeIcon] {
        guard let iconsBundle = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any?]
        else { return [] }

        guard let altIcons = iconsBundle["CFBundleAlternateIcons"] as? [String: Any?]
        else { return [] }

        let currentIconSelection = UIApplication.shared.alternateIconName

        var allIcons = [
            AlternativeIcon(id: nil, name: "Mlem", author: "By Clay/s", selected: currentIconSelection == nil)
        ]
        allIcons.append(contentsOf: altIcons.keys.map { key in
            let match = key.firstMatch(of: iconFinder)
            let name = (match?.output.1 != nil) ? String(match!.output.1) : key
            var author = (match?.output.2 != nil) ? "By \(String(match!.output.2))" : ""
            author = author.replacingOccurrences(of: "Clays", with: "Clay/s")
            return AlternativeIcon(id: key, name: name, author: author, selected: currentIconSelection == key)
        }.sorted(by: { lhs, rhs in
            lhs.name > rhs.name
        }))

        return allIcons

    }

    static func getCurrentIcon() -> some View {
        let icon = AlternativeIcon(
            id: UIApplication.shared.alternateIconName,
            name: "",
            author: "",
            selected: false
        )
        return AlternativeIconCell(icon: icon) { _ in }.getImage()
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

struct AlternativeIconsPreview: PreviewProvider {

    static var previews: some View {
        AlternativeIcons()
    }
}
