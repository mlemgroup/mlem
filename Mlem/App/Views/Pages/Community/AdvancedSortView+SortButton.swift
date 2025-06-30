//
//  AdvancedSortView+SortButton.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-12.
//

import Haptics
import MlemMiddleware
import SwiftUI

extension AdvancedSortView {
    struct SortButton: View {
        @Environment(AppState.self) var appState
        @Environment(HapticManager.self) var hapticManager
        @Environment(\.dismiss) var dismiss

        let type: PostSortType
        var timeRangeFormat: SortTimeRange.FormatStyle = .timescaleFull

        @Binding var selectedSort: PostSortType
        
        @State var showingExplanation: Bool = false
        
        var body: some View {
            HStack(spacing: Constants.main.standardSpacing) {
                Button {
                    selectedSort = type
                    dismiss()
                } label: {
                    HStack(spacing: Constants.main.standardSpacing) {
                        Image(icon: type.icon)
                            .symbolVariant(type == selectedSort ? .fill : .none)
                            .frame(width: 30, alignment: .center)
                            .foregroundStyle(type == selectedSort ? .primary : .secondary) // No palette!
                        titleView
                            .padding(.vertical, Constants.main.halfSpacing)
                        Spacer()
                        Button("Pin", icon: .lemmy.pinned) {
                            hapticManager.play(haptic: .gentleInfo, tier: .low)
                            if PinnedSortTracker.main.pinnedSortTypes.contains(type) {
                                PinnedSortTracker.main.pinnedSortTypes.remove(type)
                            } else {
                                PinnedSortTracker.main.pinnedSortTypes.insert(type)
                            }
                        }
                        .symbolVariant(PinnedSortTracker.main.pinnedSortTypes.contains(type) ? .fill : .none)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(type == selectedSort ? .themedContrastingLabel : .themedAccent)
                    }
                    .frame(minHeight: 45)
                    .buttonStyle(.plain)
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .foregroundStyle(type == selectedSort ? .themedContrastingLabel : .themedPrimary)
                    .background(
                        type == selectedSort ? .themedAccent : .themedSecondaryGroupedBackground,
                        in: .rect(cornerRadius: Constants.main.standardSpacing)
                    )
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                }
            }
            .disabled(!(appState.firstApi.supportsOrNil(.postSortType(type)) ?? true))
        }
        
        @ViewBuilder
        var titleView: some View {
            HStack(spacing: Constants.main.standardSpacing) {
                Text(type.label(timeRangeFormat: timeRangeFormat))
                if let explanation = type.explanation {
                    Button {
                        showingExplanation.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary) // No palette!
                    }
                    .popover(isPresented: $showingExplanation) {
                        PopoverContainer {
                            Text(explanation)
                                .frame(maxWidth: 200)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.footnote)
                                .padding(10)
                                .foregroundStyle(.themedPrimary)
                        }
                        .presentationCompactAdaptation(.none)
                    }
                    .environment(\.isEnabled, true) // Janky fix to override the higher-level `.disabled` modifier.
                }
            }
        }
    }
}

// https://stackoverflow.com/a/77556014/17629371
private struct PopoverContainer: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count == 1 else { fatalError() }
        let newProposal = ProposedViewSize(
            width: proposal.width ?? UIScreen.main.bounds.width,
            height: proposal.height ?? UIScreen.main.bounds.height
        )
        return subviews[0].sizeThatFits(newProposal)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // entrusts default
    }
}
