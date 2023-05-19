//
//  General.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import SwiftUI

struct GeneralSettingsView: View
{
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortTypes = .top

    var body: some View
    {
        List
        {
            Section("Sorting")
            {
                Picker(selection: $defaultCommentSorting)
                {
                    ForEach(CommentSortTypes.allCases)
                    { sortingOption in
                        Text(String(describing: sortingOption))
                    }
                } label: {
                    Label("Default comment sorting", systemImage: "arrow.up.arrow.down.square.fill")
                }
            }
        }
    }
}
