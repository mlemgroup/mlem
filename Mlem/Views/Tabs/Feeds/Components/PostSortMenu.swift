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
                    title: type.label,
                    imageName: type.iconName,
                    option: type,
                    selectedOption: $selectedSortingOption
                )
            }
            
            Menu {
                ForEach(PostSortType.topTypes, id: \.self) { type in
                    OptionButton(
                        title: type.label,
                        imageName: type.iconName,
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
                    Image(systemName: selectedSortingOption.iconName)
                        .tint(.pink)
                    Text(selectedSortingOption.label)
                        .tint(.pink)
                }
                .frame(maxWidth: .infinity)
            } else {
                Label("Selected sorting by  \"\(selectedSortingOption.description)\"", systemImage: selectedSortingOption.iconName)
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
