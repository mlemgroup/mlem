//
//  SortingSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import SwiftUI

struct SortingSettingsView: View {
    @Setting(\.defaultPostSort) var defaultPostSort
    @Setting(\.fallbackPostSort) var fallbackPostSort
    @Setting(\.commentSort) var commentSort
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Posts")
                    Spacer()
                    FeedSortPicker(sort: $defaultPostSort)
                        .frame(minHeight: 50)
                        .buttonStyle(.bordered)
                }
                if defaultPostSort.minimumVersion != .zero {
                    HStack {
                        Text("Fallback")
                        Spacer()
                        FeedSortPicker(sort: $fallbackPostSort, filters: [.alwaysAvailable])
                            .frame(minHeight: 50)
                            .buttonStyle(.bordered)
                    }
                }
            } footer: {
                if defaultPostSort.minimumVersion != .zero {
                    // swiftlint:disable:next line_length
                    Text("The \"\(defaultPostSort.fullLabel)\" sort mode is only available on instances running version \(defaultPostSort.minimumVersion.description) or later. On instances running earlier versions, the \"Fallback\" sort mode will be used instead.")
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
                    .frame(minHeight: 50)
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Sorting")
    }
}
