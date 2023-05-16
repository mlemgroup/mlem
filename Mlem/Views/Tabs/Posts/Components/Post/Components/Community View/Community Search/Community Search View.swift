//
//  Community Search View.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI

struct CommunitySearchView: View
{
    @FocusState var isSearchFieldFocused: Bool
    
    @State private var searchText: String = ""

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            CustomSearchField(text: $searchText, placeholder: "Communities")
                .focused($isSearchFieldFocused)
            Text("Ahoj")
        }
        .background(.background)
        .onAppear
        {
            isSearchFieldFocused = true
        }
        .onDisappear
        {
            isSearchFieldFocused = false
        }
    }
}
