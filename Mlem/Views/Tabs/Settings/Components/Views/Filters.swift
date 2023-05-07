//
//  Filters.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import SwiftUI

struct FiltersSettingsView: View {
    
    @EnvironmentObject var filtersTracker: FiltersTracker
    
    @State private var newFilteredKeyword: String = ""
    
    @FocusState var isKeywordAdditionFieldFocused
    
    var body: some View {
        List
        {
            Section {
                ForEach(filtersTracker.filteredKeywords, id: \.self)
                { filteredKeyword in
                    Text(filteredKeyword)
                }
                .onDelete(perform: deleteKeyword)
                
                TextField("Add Keyword…", text: $newFilteredKeyword, prompt: Text("Add Keyword…"))
                    .submitLabel(.done)
                    .onSubmit {
                        isKeywordAdditionFieldFocused = true
                        
                        withAnimation {
                            filtersTracker.filteredKeywords.prepend(newFilteredKeyword)
                        }
                        
                        newFilteredKeyword = ""
                    }
                    .focused($isKeywordAdditionFieldFocused)
            } header: {
                Text("Filtered Keywords")
            } footer: {
                Text("Posts containing these keywords in their title will not be shown")
            }

        }
        .toolbar
        {
            ToolbarItem(placement: .automatic) {
                EditButton()
            }
        }
    }
    
    func deleteKeyword(at offsets: IndexSet)
    {
        filtersTracker.filteredKeywords.remove(atOffsets: offsets)
    }
}

