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
            Section("Default Sorting")
            {
                Picker(selection: $defaultCommentSorting)
                {
                    ForEach(CommentSortTypes.allCases)
                    { sortingOption in
                        Text(String(describing: sortingOption))
                    }
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "arrow.up.arrow.down.square.fill")
                            .foregroundColor(.gray)
                        Text("Comment sorting")
                    }
                }
            }
        }
    }
}
