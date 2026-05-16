//
//  QuickSwipesViewModifier.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-23.
//

import ComponentViews
import Haptics
import Icons
import MlemLogger
import os
import SwiftUI
import Theming

// swiftlint:disable:next type_body_length
struct QuickSwipeViewModifier: ViewModifier {
    let log: Logger = .mlemLogger()
    
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.palette) var palette
    
    @Environment(\.quickSwipeThresholdSet) var thresholds
    @Environment(\.quickSwipeMinimumDrag) var minimumDrag
    @Environment(\.quickSwipeIconSize) var iconSize
    @Environment(\.quickSwipeCornerRadius) var cornerRadius
    @Environment(\.quickSwipesEnabled) var quickSwipesEnabled
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: ThemedColor? = .themedBackground
    @State var leadingSwipeIcon: Icon?
    @State var trailingSwipeIcon: Icon?
    @State var iconIsActive: Bool = false
    @State var activeChoiceGroup: QuickSwipeChoiceGroup?
    
    let config: SwipeConfiguration
    
    private var primaryLeadingAction: QuickSwipeAction? { config.leadingActions.first }
    private var primaryTrailingAction: QuickSwipeAction? { config.trailingActions.first }
    
    init(config: SwipeConfiguration) {
        self.config = config
        
        _leadingSwipeIcon = State(initialValue: primaryLeadingAction?.icon)
        _trailingSwipeIcon = State(initialValue: primaryTrailingAction?.icon)
    }
    
    func body(content: Content) -> some View {
        if quickSwipesEnabled {
            innerBody(content: content)
                .clipShape(.rect(cornerRadius: cornerRadius)) // clip slidable card
                .background(shadowBackground)
                .geometryGroup()
                .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
                .background(iconBackground)
                // disables links from highlighting when tapped
                .buttonStyle(.empty)
                .clipShape(.rect(cornerRadius: cornerRadius)) // clip entire view
                .versionAwareDialog(
                    activeChoiceGroup?.title ?? "",
                    isPresented: .init(get: { activeChoiceGroup != nil }, set: { _ in activeChoiceGroup = nil })
                ) {
                    ForEach(Array((activeChoiceGroup?.items ?? []).enumerated()), id: \.offset) { _, item in
                        Button(item.label, role: item.destructive ? .destructive : nil, action: item.callback)
                    }
                    Button("Cancel", role: .cancel) {}
                }
        } else {
            content
                .clipShape(.rect(cornerRadius: cornerRadius)) // clip entire view
        }
    }
    
    @ViewBuilder
    func innerBody(content: Content) -> some View {
        content
            .gesture(
                PanGesture(leadingBuffer: config.leadingBuffer.value) { recognizer in
                    if [.ended, .cancelled].contains(recognizer.state) {
                        draggingUpdated(dragState: 0)
                    } else {
                        draggingUpdated(dragState: recognizer.translation(in: recognizer.view).x)
                    }
                }
            )
    }
    
    var shadowBackground: some View {
        // creates a shadow under the edge of the view
        Rectangle()
            .foregroundStyle(.clear)
            .border(width: 10, edges: [.leading, .trailing], color: .black)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: 5)
            .opacity(dragPosition == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
    }
    
    var iconBackground: some View {
        dragBackground?.resolve(with: palette)
            .overlay {
                HStack(spacing: 0) {
                    if dragPosition > 0 {
                        iconView(leadingSwipeIcon)
                    }
                    Spacer()
                    if dragPosition < 0 {
                        iconView(trailingSwipeIcon)
                    }
                }
                .accessibilityHidden(true) // prevent these from popping up in VO
                .opacity(dragPosition == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
            }
    }
    
    func iconView(_ icon: Icon?) -> some View {
        Image(icon: icon?.representingState(active: iconIsActive) ?? .general.warning)
            .font(.system(size: iconSize))
            .foregroundStyle(.themedContrastingLabel)
            .frame(width: iconWidth)
            .padding(.horizontal, iconWidth)
    }
    
    private func draggingUpdated(dragState: CGFloat) {
        // if dragState changes and is now 0, gesture has ended; compute action based on last detected position
        if dragState == .zero {
            draggingDidEnd()
        } else {
            guard shouldRespondToDragPosition(dragState) else {
                // as swipe actions are optional we don't allow dragging without a primary action
                return
            }
            
            // update position
            dragPosition = dragState
            
            let edgeForActions = edgeForActions(at: dragPosition)
            let actionIndex = actionIndex(edge: edgeForActions, at: dragPosition)
            let action = action(edge: edgeForActions, index: actionIndex)
            let threshold = actionThreshold(edge: edgeForActions, index: actionIndex)
            
            // update color and symbol. If crossed an edge, play a gentle haptic
            switch edgeForActions {
            case .leading:
                if actionIndex == nil {
                    iconIsActive = false
                    leadingSwipeIcon = primaryLeadingAction?.icon
                    dragBackground = primaryLeadingAction?.color.opacity(dragPosition / threshold)
                } else {
                    iconIsActive = true
                    leadingSwipeIcon = action?.icon
                    dragBackground = action?.color.opacity(dragPosition / threshold)
                }
            case .trailing:
                if actionIndex == nil {
                    iconIsActive = false
                    trailingSwipeIcon = primaryTrailingAction?.icon
                    dragBackground = primaryTrailingAction?.color.opacity(dragPosition / threshold)
                } else {
                    iconIsActive = true
                    trailingSwipeIcon = action?.icon
                    dragBackground = action?.color.opacity(dragPosition / threshold)
                }
            }
            
            // If crossed an edge, play a gentle haptic
            let previousIndex = self.actionIndex(edge: edgeForActions, at: prevDragPosition)
            let currentIndex = self.actionIndex(edge: edgeForActions, at: dragPosition)
            if let hapticInfo = hapticInfo(transitioningFrom: previousIndex, to: currentIndex) {
                hapticManager.play(haptic: hapticInfo.0, tier: hapticInfo.1)
            }
                          
            prevDragPosition = dragPosition
        }
    }
    
    private func draggingDidEnd() {
        let finalDragPosition = prevDragPosition
        
        reset()
        
        let action = swipeAction(at: finalDragPosition)
        
        switch action?.perform {
        case let .callback(callback, confirmationPrompt):
            if let confirmationPrompt {
                activeChoiceGroup = .init(
                    title: confirmationPrompt,
                    items: [.init(label: "Confirm", destructive: true, callback: callback)]
                )
            } else {
                callback()
            }
        case let .choice(choiceGroup):
            activeChoiceGroup = choiceGroup
        case nil:
            break
        }
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.25)) {
            dragPosition = .zero
            prevDragPosition = .zero
            leadingSwipeIcon = primaryLeadingAction?.icon
            trailingSwipeIcon = primaryTrailingAction?.icon
            dragBackground = .themedBackground
        }
    }
    
    private func shouldRespondToDragPosition(_ position: CGFloat) -> Bool {
        if position > 0, primaryLeadingAction == nil {
            return false
        }
        
        if position < 0, primaryTrailingAction == nil {
            return false
        }
        
        return true
    }
    
    // MARK: -
    
    /// Get the swipe action a specific drag position.
    /// - Parameter dragPosition: Along the x-axis.
    private func swipeAction(at dragPosition: CGFloat) -> (QuickSwipeAction)? {
        let edge = edgeForActions(at: dragPosition)
        let index = actionIndex(edge: edge, at: dragPosition)
        let action = action(edge: edge, index: index)
        return action
    }
    
    /// For a particular `dragPosition`, returns the relevant edge for which to show/perform actions.
    private func edgeForActions(at dragPosition: CGFloat) -> HorizontalEdge {
        dragPosition > 0 ? .leading : .trailing
    }
    
    /// Index of the action along the specified edge at the specified drag position.
    /// - Returns: A `nil` value denotes the state where swiping has begun, but not enough to trigger any actions.
    private func actionIndex(edge: HorizontalEdge, at dragPosition: CGFloat) -> Array<CGFloat>.Index? {
        /// Map a `dragPosition` to a `dragThreshold`, which tells us what swipe action to perform, where `nil` is no action, `1` is primary, `2` is secondary, etc.
        let thresholdIndex = thresholds.all.lastIndex {
            switch edge {
            case .leading:
                return dragPosition > $0
            case .trailing:
                return dragPosition < -$0
            }
        }
        
        guard let thresholdIndex else {
            return nil
        }
        
        /// There may not be an associated action for a threshold.
        switch edge {
        case .leading:
            if thresholdIndex > (config.leadingActions.endIndex - 1) {
                log.debug("leading action not configured for this threshold")
                return config.leadingActions.endIndex - 1
            }
            return thresholdIndex
        case .trailing:
            if thresholdIndex > (config.trailingActions.endIndex - 1) {
                log.debug("trailing action not configured for this threshold")
                return config.trailingActions.endIndex - 1
            }
            return thresholdIndex
        }
    }
    
    /// Get the action associated with an edge at the specified index.
    private func action(edge: HorizontalEdge, index actionIndex: Array<CGFloat>.Index?) -> (QuickSwipeAction)? {
        guard let actionIndex else {
            return nil
        }
        switch edge {
        case .leading:
            return config.leadingActions[safeIndex: actionIndex]
        case .trailing:
            return config.trailingActions[safeIndex: actionIndex]
        }
    }
    
    /// Maps swipe action transitions into an appropriate haptic info payload for haptic playback purposes.
    /// - No-op if both indexes are the same (i.e. transition isn't happening).
    private func hapticInfo(
        transitioningFrom previousIndex: Array<CGFloat>.Index?,
        to currentIndex: Array<CGFloat>.Index?
    ) -> (Haptic, HapticTier)? {
        guard previousIndex != currentIndex else {
            /// Same action, don't play haptic.
            return nil
        }
        
        // From nil -> 0 -> 1 -> 2, etc, where nil is no action, and 0 is the primary action.
        // Swiping towards to primary action.
        // Index values are always >= 0 for both leading/trailing edges.
        // Since nil indicates no action, we use -1 to represent nil instead (lol, yes).
        if (currentIndex ?? -1) < (previousIndex ?? -1) {
            return (.mushyInfo, .low)
        } else {
            if previousIndex == nil {
                return (.gentleInfo, .high)
            } else if previousIndex == 1 {
                return (.firmInfo, .high)
            } else {
                return (.firmInfo, .high)
            }
        }
    }
    
    /// Get the threshold (in screen points) required to trigger a particular action.
    /// - Parameter edge: Show actions on this edge.
    /// - Parameter index: Index of the action in question.
    /// - Returns: Negative values for trailing actions along the x-axis.
    private func actionThreshold(
        edge edgeForActions: HorizontalEdge,
        index actionIndex: Array<CGFloat>.Index?
    ) -> CGFloat {
        guard let actionIndex else {
            switch edgeForActions {
            case .leading:
                return thresholds.primary
            case .trailing:
                return -thresholds.primary
            }
        }
        
        switch edgeForActions {
        case .leading:
            return thresholds.all[actionIndex]
        case .trailing:
            return -thresholds.all[actionIndex]
        }
    }
    
    private var iconWidth: CGFloat {
        // this sets the icon to always be centered between the edge of the background and the edge of the swipeable item, as this is
        // both the width of the icon's frame and its padding. the actual icon size is done using fonts.
        thresholds.primary / 3
    }
}
