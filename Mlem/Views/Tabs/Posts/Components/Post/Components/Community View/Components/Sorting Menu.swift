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
            
            OptionButton(
                title: "New Comments",
                imageName: "ellipsis.bubble",
                option: .newComments,
                selectedOption: $selectedSortingOption
            )
            
            OptionButton(
                title: "Most Comments",
                imageName: "chart.line.uptrend.xyaxis",
                option: .mostComments,
                selectedOption: $selectedSortingOption
            )
            
            OptionButton(
                title: "Old",
                imageName: "books.vertical",
                option: .old,
                selectedOption: $selectedSortingOption
            )
            
            Menu {
                OptionButton(
                    title: "Hour",
                    imageName: "calendar.day.timeline.left",
                    option: .topHour,
                    selectedOption: $selectedSortingOption
                )
                
                OptionButton(
                    title: "Six Hours",
                    imageName: "calendar.day.timeline.left",
                    option: .topSixHour,
                    selectedOption: $selectedSortingOption
                )
                
                OptionButton(
                    title: "Twelve Hours",
                    imageName: "calendar.day.timeline.left",
                    option: .topTwelveHour,
                    selectedOption: $selectedSortingOption
                )
                
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
            case .mostComments:
                Label("Selected sorting by \"Most comments\"", systemImage: "calendar.day.timeline.left")
            case .old:
                Label("Selected sorting by \"Old\"", systemImage: "books.vertical")
            case .newComments:
                Label("Selected sorting by \"New comments\"", systemImage: "calendar.day.timeline.left")
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
            case .topHour:
                Label("Selected sorting by \"Top of the last hour\"", systemImage: "calendar.day.timeline.left")
            case .topSixHour:
                Label("Selected sorting by \"Top of the last six hours\"", systemImage: "calendar.day.timeline.left")
            case .topTwelveHour:
                Label("Selected sorting by \"Top of the last twelve hours\"", systemImage: "calendar.day.timeline.left")
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
