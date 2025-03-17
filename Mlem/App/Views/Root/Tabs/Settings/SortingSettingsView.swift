//
//  SortingSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import SwiftUI

struct SortingSettingsView: View {
    @Setting(\.defaultPostSort) var legacyDefaultPostSort
    @Setting(\.fallbackPostSort) var legacyFallbackPostSort
    @Setting(\.commentSort) var commentSort
    
    var defaultPostSort: PostSortType {
        get { .init(legacyDefaultPostSort) }
        nonmutating set { legacyDefaultPostSort = newValue.legacyApiSortType ?? .hot }
    }
    
    var fallbackPostSort: PostSortType {
        get { .init(legacyFallbackPostSort) }
        nonmutating set { legacyFallbackPostSort = newValue.legacyApiSortType ?? .hot }
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Sorting",
                description: "Choose the default sort mode for posts and comments.",
                systemImage: "arrow.up.and.down.text.horizontal"
            )
            .tint(.themedColorfulAccent(5))
            Section {
                HStack {
                    Text("Posts")
                    Spacer()
                    FeedSortPicker(sort: .init(
                        get: { defaultPostSort }, set: { defaultPostSort = $0 }
                    ))
                    .foregroundStyle(.themedAccent)
                    .frame(minHeight: 50)
                    .buttonStyle(.bordered)
                }
                if defaultPostSort.minimumVersion != .zero {
                    HStack {
                        Text("Fallback")
                        Spacer()
                        FeedSortPicker(sort: .init(
                            get: { defaultPostSort }, set: { defaultPostSort = $0 }
                        ))
                        .foregroundStyle(.themedAccent)
                        .frame(minHeight: 50)
                        .buttonStyle(.bordered)
                    }
                }
            } footer: {
                if defaultPostSort.minimumVersion != .zero {
                    // swiftlint:disable:next line_length
                    Text("The \"\(defaultPostSort.label())\" sort mode is only available on instances running version \(defaultPostSort.minimumVersion.description) or later. On instances running earlier versions, the \"Fallback\" sort mode will be used instead.")
                }
            }
            
            Section {
                HStack {
                    Text("Comments")
                    Spacer()
                    Menu(String(localized: commentSort.label), systemImage: commentSort.systemImage) {
                        Picker("Sort", selection: $commentSort) {
                            ForEach(ApiCommentSortType.allCases, id: \.self) { item in
                                Label(String(localized: item.label), systemImage: item.systemImage)
                            }
                        }
                    }
                    .foregroundStyle(.themedAccent)
                    .frame(minHeight: 50)
                    .buttonStyle(.bordered)
                }
            }
        }
        .contentMargins(.top, 16)
    }
}
