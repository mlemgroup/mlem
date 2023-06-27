//
//  Sorting Menu.swift
//  Mlem
//
//  Created by David Bureš on 02.06.2023.
//

import SwiftUI

struct PostSortMenu: View {
    
    @Binding var selectedSortingOption: PostSortType
    var shortLabel: Bool = false
    
    var body: some View {
        
        Menu {
            ForEach(PostSortType.outerTypes, id: \.self) { type in
                OptionButton(
                    title: type.shortDescription,
                    imageName: type.imageName,
                    option: type,
                    selectedOption: $selectedSortingOption
                )
            }
            
            Menu {
                ForEach(PostSortType.topTypes, id: \.self) { type in
                    OptionButton(
                        title: type.shortDescription,
                        imageName: type.imageName,
                        option: type,
                        selectedOption: $selectedSortingOption
                    )
                }
                
            } label: {
                Label("Top…", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
        } label: {
            if shortLabel {
                HStack {
                    Spacer()
                    Image(systemName: selectedSortingOption.imageName)
                        .tint(.pink)
                    Text(selectedSortingOption.shortDescription)
                        .tint(.pink)
                }
                .frame(maxWidth: .infinity)
            } else {
                Label("Selected sorting by  \"\(selectedSortingOption.description)\"", systemImage: selectedSortingOption.imageName)
            }
        }
    }
}

private struct OptionButton<Option: Equatable>: View {
    
    let title: String
    let imageName: String
    let option: Option
    @Binding var selectedOption: Option
    
    var body: some View {
        Button {
            selectedOption = option
        } label: {
            Label(title, systemImage: imageName)
        }
        .disabled(option == selectedOption)
    }
}
