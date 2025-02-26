//
//  AdvancedSortView+SortButton.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-12.
//

import MlemMiddleware
import SwiftUI

extension AdvancedSortView {
    struct SortButton: View {
        @Environment(AppState.self) var appState
        @Environment(Palette.self) var palette
        @Environment(\.dismiss) var dismiss

        let type: ApiSortType
        var topFormat: ApiSortType.TopSortModeFormatStyle = .timescaleFull

        @Binding var selectedSort: ApiSortType
        
        @State var showingExplanation: Bool = false
        
        var body: some View {
            HStack(spacing: Constants.main.standardSpacing) {
                Button {
                    selectedSort = type
                    dismiss()
                } label: {
                    HStack(spacing: Constants.main.standardSpacing) {
                        Image(systemName: type.systemImage)
                            .symbolVariant(type == selectedSort ? .fill : .none)
                            .frame(width: 30, alignment: .center)
                            .foregroundStyle(type == selectedSort ? .primary : .secondary) // No palette!
                        VStack(alignment: .leading) {
                            titleView
                            if (appState.firstApi.fetchedVersion ?? .infinity) < type.minimumVersion {
                                Text("Requires Lemmy \(String(describing: type.minimumVersion)) or later")
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(palette.warning)
                                    .font(.footnote)
                            }
                        }
                        .padding(.vertical, Constants.main.halfSpacing)
                        Spacer()
                        Button("Pin", systemImage: PinnedSortTracker.main.pinnedSortTypes.contains(type) ? Icons.pinFill : Icons.pin) {
                            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                            if PinnedSortTracker.main.pinnedSortTypes.contains(type) {
                                PinnedSortTracker.main.pinnedSortTypes.remove(type)
                            } else {
                                PinnedSortTracker.main.pinnedSortTypes.insert(type)
                            }
                        }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(type == selectedSort ? palette.selectedInteractionBarItem : palette.accent)
                    }
                    .frame(minHeight: 45)
                    .buttonStyle(.plain)
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .foregroundStyle(type == selectedSort ? palette.selectedInteractionBarItem : palette.primary)
                    .background(
                        type == selectedSort ? palette.accent : palette.secondaryGroupedBackground,
                        in: .rect(cornerRadius: Constants.main.standardSpacing)
                    )
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                }
            }
            .disabled((appState.firstApi.fetchedVersion ?? .infinity) < type.minimumVersion)
        }
        
        @ViewBuilder
        var titleView: some View {
            HStack(spacing: Constants.main.standardSpacing) {
                Text(type.label(topFormat: topFormat))
                if let explanation = type.explanation {
                    Button {
                        showingExplanation.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary) // No palette!
                    }
                    .popover(isPresented: $showingExplanation) {
                        PopoverContainer {
                            Text(LocalizedStringKey(explanation))
                                .frame(maxWidth: 200)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.footnote)
                                .padding(10)
                                .foregroundStyle(palette.primary)
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
