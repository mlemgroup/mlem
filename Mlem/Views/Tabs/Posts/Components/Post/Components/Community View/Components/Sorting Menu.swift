//
//  Sorting Menu.swift
//  Mlem
//
//  Created by David Bureš on 02.06.2023.
//

import SwiftUI

struct SortingMenu: View {
    
    @Binding var selectedSortingOption: SortingOptions
    
    var body: some View {
        Menu
        {
            OptionButton(
                title: "Active",
                imageName: "bubble.left.and.bubble.right",
                option: .active,
                selectedOption: $selectedSortingOption
            )
            
            OptionButton(
                title: "Hot",
                imageName: "flame",
                option: .hot,
                selectedOption: $selectedSortingOption
            )

            OptionButton(
                title: "New",
                imageName: "sun.max",
                option: .new,
                selectedOption: $selectedSortingOption
            )
            
            Menu {
                OptionButton(
                    title: "Day",
                    imageName: "calendar.day.timeline.left",
                    option: .topDay,
                    selectedOption: $selectedSortingOption
                )

                OptionButton(
                    title: "Week",
                    imageName: "calendar.day.timeline.left",
                    option: .topWeek,
                    selectedOption: $selectedSortingOption
                )
                
                OptionButton(
                    title: "Month",
                    imageName: "calendar.day.timeline.left",
                    option: .topMonth,
                    selectedOption: $selectedSortingOption
                )

                OptionButton(
                    title: "Year",
                    imageName: "calendar.day.timeline.left",
                    option: .topYear,
                    selectedOption: $selectedSortingOption
                )

                OptionButton(
                    title: "All time",
                    imageName: "calendar.day.timeline.left",
                    option: .topAll,
                    selectedOption: $selectedSortingOption
                )
            } label: {
                Label("Top…", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
        } label: {
            switch selectedSortingOption
            {
                case .active:
                    Label("Selected sorting by  \"Active\"", systemImage: "bubble.left.and.bubble.right")
                case .hot:
                    Label("Selected sorting by \"Hot\"", systemImage: "flame")
                case .new:
                    Label("Selected sorting by \"New\"", systemImage: "sun.max")
                case .topDay:
                    Label("Selected sorting by \"Top of Day\"", systemImage: "calendar.day.timeline.left")
                case .topWeek:
                    Label("Selected sorting by \"Top of Week\"", systemImage: "calendar.day.timeline.left")
                case .topMonth:
                    Label("Selected sorting by \"Top of Month\"", systemImage: "calendar.day.timeline.left")
                case .topYear:
                    Label("Selected sorting by \"Top of Year\"", systemImage: "calendar.day.timeline.left")
                case .topAll:
                    Label("Selected sorting by \"Top of All Time\"", systemImage: "calendar.day.timeline.left")
            }
        }
    }
}

struct OptionButton<Option: Equatable>: View {
    
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
