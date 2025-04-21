//
//  SortingSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import SwiftUI

struct SortingSettingsView: View {
    @Setting(\.post_defaultSort) var legacyDefaultPostSort
    @Setting(\.post_fallbackSort) var legacyFallbackPostSort
    @Setting(\.comment_defaultSort) var legacyDefaultCommentSort
    
    var defaultPostSort: PostSortType {
        get { .init(legacyDefaultPostSort) }
        nonmutating set { legacyDefaultPostSort = newValue.legacyApiSortType ?? .hot }
    }
    
    var fallbackPostSort: PostSortType {
        get { .init(legacyFallbackPostSort) }
        nonmutating set { legacyFallbackPostSort = newValue.legacyApiSortType ?? .hot }
    }
    
    var defaultCommentSort: CommentSortType {
        get { .init(legacyDefaultCommentSort) }
        nonmutating set { legacyDefaultCommentSort = newValue.apiSortType }
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Sorting",
                description: "Choose the default sort mode for posts and comments.",
                icon: .settings.sorting
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
                            get: { fallbackPostSort }, set: { fallbackPostSort = $0 }
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
                    Menu(defaultCommentSort.label(timeRangeFormat: .topOnly), icon: defaultCommentSort.icon) {
                        Picker("Sort", selection: .init(get: { defaultCommentSort }, set: { defaultCommentSort = $0 })) {
                            ForEach(CommentSortType.legacyCases, id: \.self) { item in
                                Label(item.label(timeRangeFormat: .topOnly), icon: item.icon)
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
        .hiddenNavigationTitle("Sorting")
    }
}
