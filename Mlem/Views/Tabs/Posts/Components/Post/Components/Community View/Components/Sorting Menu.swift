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
            Button
            {
                selectedSortingOption = .active
            } label: {
                Label("Active", systemImage: "bubble.left.and.bubble.right")
            }
            
            Button
            {
                selectedSortingOption = .hot
            } label: {
                Label("Hot", systemImage: "flame")
            }
            
            Button
            {
                selectedSortingOption = .new
            } label: {
                Label("New", systemImage: "sun.max")
            }
            
            Menu
            {
                Button
                {
                    selectedSortingOption = .topDay
                } label: {
                    Label("Day", systemImage: "calendar.day.timeline.left")
                }
                
                Button
                {
                    selectedSortingOption = .topWeek
                } label: {
                    Label("Week", systemImage: "calendar.day.timeline.left")
                }
                
                Button
                {
                    selectedSortingOption = .topMonth
                } label: {
                    Label("Month", systemImage: "calendar.day.timeline.left")
                }
                
                Button
                {
                    selectedSortingOption = .topYear
                } label: {
                    Label("Year", systemImage: "calendar.day.timeline.left")
                }
                
                Button
                {
                    selectedSortingOption = .topAll
                } label: {
                    Label("All time", systemImage: "calendar.day.timeline.left")
                }
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
                    
#warning("TODO: Make this the default icon for the sorting")
                    /* case .unspecified:
                     Label("Sort posts", systemImage: "arrow.up.and.down.text.horizontal") */
            }
        }
    }
}
