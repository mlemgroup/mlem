//
//  PostSortPickerView.swift
//  Mlem
//
//  Created by Sjmarf on 10/09/2023.
//

import SwiftUI
import Dependencies

private enum PostSortSection: String {
    case root = "Root"
    case age = "Age"
    case comments = "Comments"
    case top = "Top"
    
    var children: [PostSortType] {
        switch self {
        case .root:
            return []
        case .age:
            return [.new, .old]
        case .comments:
            return [.newComments, .mostComments, .active]
        case .top:
            return [
                .topSixHour,
                .topTwelveHour,
                .topDay,
                .topWeek,
                .topMonth,
                .topThreeMonth,
                .topSixMonth,
                .topNineMonth,
                .topYear,
                .topAll
            ]
        }
    }
    
    var iconName: String {
        switch self {
        case .root:
            return ""
        case .age:
            return "clock"
        case .comments:
            return "bubble.left"
        case .top:
            return "trophy"
        }
    }
}

struct PostSortPickerView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @State private var selectionStage: PostSortSection = .root
    @State private var tempSelected: PostSortType
    
    @Binding var isPresented: Bool
    @Binding var selected: PostSortType
    
    init(isPresented: Binding<Bool>, selected: Binding<PostSortType>) {
        _isPresented = isPresented
        _selected = selected
        _tempSelected = State(initialValue: selected.wrappedValue)
    }
    
    var body: some View {
        VStack {
            if selectionStage != .top {
                VStack(alignment: .leading, spacing: 15) {
                    sortOption(.hot)
                    if selectionStage != .age {
                        sortSubmenu(.age)
                    } else {
                        HStack(spacing: 15) {
                            sortOption(.new, stage: .age)
                            sortOption(.old, stage: .age)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    if selectionStage != .comments {
                        sortSubmenu(.comments)
                    } else {
                        HStack(spacing: 15) {
                            sortOption(.newComments, stage: .comments)
                            sortOption(.mostComments, stage: .comments)
                            sortOption(.active, stage: .comments)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    sortSubmenu(.top)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 15) {
                        sortOption(.topHour, stage: .top, showIcon: false)
                        sortOption(.topSixHour, stage: .top, showIcon: false)
                        sortOption(.topTwelveHour, stage: .top, showIcon: false)
                    }
                    HStack(spacing: 15) {
                        sortOption(.topDay, stage: .top, showIcon: false)
                        sortOption(.topWeek, stage: .top, showIcon: false)
                        sortOption(.topMonth, stage: .top, showIcon: false)
                    }
                    HStack(spacing: 15) {
                        sortOption(.topThreeMonth, stage: .top, showIcon: false)
                        sortOption(.topSixMonth, stage: .top, showIcon: false)
                        sortOption(.topNineMonth, stage: .top, showIcon: false)
                    }
                    HStack(spacing: 15) {
                        sortOption(.topYear, stage: .top, showIcon: false)
                        sortOption(.topAll, stage: .top, showIcon: false)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(
            .spring(duration: 0.5, bounce: 0.3),
            value: selectionStage
        )
        .onDisappear {
            selected = tempSelected
        }
        .onTapGesture {
            selectionStage = .root
        }
    }
    
    @ViewBuilder
    private func sortOption(_ sortType: PostSortType, stage: PostSortSection = .root, showIcon: Bool = true) -> some View {
        let isDisabled = (stage == .root && (selectionStage != .root))
        Button {
            tempSelected = sortType
            selectionStage = .root
        } label: {
            if showIcon {
                Label(sortType.switcherLabel, systemImage: sortType.iconName)
            } else {
                Text(sortType.switcherLabel)
            }
        }
        .buttonStyle(SortMenuButtonStyle(isSelected: sortType == tempSelected))
        .disabled(isDisabled)
        .shadow(color: (stage != .root) && (stage == selectionStage) ? .black.opacity(0.05) : .clear, radius: 5, x: 5, y: 5)
        .animation(.easeOut(duration: 0.2), value: tempSelected)
        .animation(.easeOut(duration: 0.2), value: selectionStage)
        .accessibilityHidden(isDisabled)
    }
    
    @ViewBuilder
    private func sortSubmenu(_ stage: PostSortSection) -> some View {
        let isSelected = stage.children.contains(tempSelected)
        Button {
            selectionStage = stage
        } label: {
            let text = isSelected ? "\(stage.rawValue) (\(tempSelected.switcherLabel))" : "\(stage.rawValue)..."
            Label(text, systemImage: stage.iconName)
        }
        .buttonStyle(SortMenuButtonStyle(isSelected: isSelected))
        .transition(.scale.combined(with: .opacity))
        .disabled(selectionStage != .root)
        .animation(.easeOut(duration: 0.2), value: tempSelected)
        .animation(.easeOut(duration: 0.2), value: selectionStage)
        .accessibilityHidden(selectionStage != .root)
    }
}
