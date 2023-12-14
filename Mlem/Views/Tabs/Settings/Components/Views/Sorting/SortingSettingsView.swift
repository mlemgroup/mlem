//
//  SortingSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 21/10/2023.
//

import Dependencies
import SwiftUI

struct SortingSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @EnvironmentObject var appState: AppState
    
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
    
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top

    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = false

    var body: some View {
        List {
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: defaultPostSorting.iconName,
                    settingName: "Posts",
                    currentValue: $defaultPostSorting,
                    options: PostSortType.allCases
                )
                if !PostSortType.alwaysAvailableTypes.contains(defaultPostSorting) {
                    SelectableSettingsItem(
                        settingIconSystemName: fallbackDefaultPostSorting.iconName,
                        settingName: "Fallback",
                        currentValue: $fallbackDefaultPostSorting,
                        options: PostSortType.alwaysAvailableTypes
                    )
                }
            } footer: {
                if PostSortType.alwaysAvailableTypes.contains(defaultPostSorting) {
                    Text("The sort mode that is selected by default when you open a feed.")
                } else {
                    // swiftlint:disable line_length
                    Text("You've selected the '\(defaultPostSorting.label)' sort mode, which is only available on instances running v\(String(describing: defaultPostSorting.minimumVersion)) or later. \(appState.currentActiveAccount?.instanceLink.host ?? "your instance") is running v\(String(describing: siteInformation.version ?? .zero)).\n\nWhen using an instance older than v\(String(describing: defaultPostSorting.minimumVersion)), the 'fallback' sort mode will be used instead."
                    )
                    // swiftlint:enable line_length
                }
            }
            
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: defaultCommentSorting.iconName,
                    settingName: "Comments",
                    currentValue: $defaultCommentSorting,
                    options: CommentSortType.allCases
                )
            } footer: {
                Text("The sort mode that is selected by default when you open a post.")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Sorting")
        .navigationBarColor()
        .hoistNavigation()
    }
}
