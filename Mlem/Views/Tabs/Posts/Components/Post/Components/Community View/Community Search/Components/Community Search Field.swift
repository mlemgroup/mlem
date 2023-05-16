//
//  Community Search Field.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI

struct CommunitySearchField: View {
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    @Binding var searchText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack
            {
                Spacer()
                TextField("Community…", text: $searchText)
                    .focused($isSearchFieldFocused)
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
}

