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
    
    var body: some View {
        List
        {
            Section {
                ForEach(filtersTracker.filteredKeywords, id: \.self)
                { filteredKeyword in
                    Text(filteredKeyword)
                }
                .onDelete(perform: deleteKeyword)
                
                HStack(alignment: .center) {
                    TextField("Add Keyword…", text: $newFilteredKeyword, prompt: Text("Add Keyword…"))
                    
                    Spacer()
                    
                    Button {
                        addKeyword(newFilteredKeyword)
                    } label: {
                        Text("Add")
                    }
                    .disabled(newFilteredKeyword.isEmpty)

                }
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
    
    func addKeyword(_ newKeyword: String)
    {
        if !newKeyword.isEmpty
        {
            if filtersTracker.filteredKeywords.contains(newKeyword)
            { /// If the word is already in there, just move it to the top
                let indexOfPreviousOccurence: Int = filtersTracker.filteredKeywords.firstIndex(where: { $0 == newKeyword })!
                withAnimation {
                    filtersTracker.filteredKeywords.move(from: indexOfPreviousOccurence, to: 0)
                }
            }
            else
            {
                withAnimation {
                    filtersTracker.filteredKeywords.prepend(newKeyword)
                }
            }
            
            newFilteredKeyword = ""
        }
    }
    func deleteKeyword(at offsets: IndexSet)
    {
        filtersTracker.filteredKeywords.remove(atOffsets: offsets)
    }
}

