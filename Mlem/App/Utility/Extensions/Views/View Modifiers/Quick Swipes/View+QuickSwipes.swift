//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import Dependencies
import SwiftUI

struct QuickSwipeView: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    @Setting(\.quickSwipesEnabled) var quickSwipesEnabled
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color? = Palette.main.background
    @State var leadingSwipeSymbol: String?
    @State var trailingSwipeSymbol: String?
    
    let config: SwipeConfiguration
    
    private let iconWidth: CGFloat
    
    private var primaryLeadingAction: (any Action)? { config.leadingActions.first }
    private var primaryTrailingAction: (any Action)? { config.trailingActions.first }
    
    init(config: SwipeConfiguration) {
        self.config = config
        
        // this sets the icon to always be centered between the edge of the background and the edge of the swipeable item, as this is
        // both the width of the icon's frame and its padding. the actual icon size is done using fonts.
        self.iconWidth = config.behavior.primaryThreshold / 3
        
        _leadingSwipeSymbol = State(initialValue: primaryLeadingAction?.swipeIcon1)
        _trailingSwipeSymbol = State(initialValue: primaryTrailingAction?.swipeIcon1)
    }
    
    func body(content: Content) -> some View {
        if quickSwipesEnabled {
            content
                .background(shadowBackground)
                .geometryGroup()
                .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
                .highPriorityGesture(
                    DragGesture(
                        minimumDistance: config.behavior.minimumDrag, // min distance prevents conflict with scrolling drag gesture
                        coordinateSpace: .global
                    )
                    .updating($dragState) { value, state, _ in
                        // this check adds a dead zone to the left side of the screen so it doesn't interfere with navigation
                        if dragState == .zero && abs(value.translation.height) * 1.7 > abs(value.translation.width) {
                            return
                        }
                        if dragState != .zero || value.location.x > 70 {
                            state = value.translation.width
                        }
                    }
                )
                .background(iconBackground)
                .onChange(of: dragState, draggingUpdated)
                // disables links from highlighting when tapped
                .buttonStyle(EmptyButtonStyle())
                .clipShape(RoundedRectangle(cornerRadius: config.behavior.cornerRadius))
        } else {
            content
        }
    }
    
    var shadowBackground: some View {
        // creates a shadow under the edge of the view
        Rectangle()
            .foregroundStyle(.clear)
            .border(width: 10, edges: [.leading, .trailing], color: .black)
            .clipShape(RoundedRectangle(cornerRadius: config.behavior.cornerRadius))
            .shadow(radius: 5)
            .opacity(dragState == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
    }
    
    var iconBackground: some View {
        dragBackground
            .overlay {
                HStack(spacing: 0) {
                    if dragState > 0 {
                        Image(systemName: leadingSwipeSymbol ?? Icons.warning)
                            .font(.system(size: config.behavior.iconSize))
                            .foregroundColor(palette.selectedInteractionBarItem)
                            .frame(width: iconWidth)
                            .padding(.horizontal, iconWidth)
                    }
                    Spacer()
                    if dragState < 0 {
                        Image(systemName: trailingSwipeSymbol ?? Icons.warning)
                            .font(.system(size: config.behavior.iconSize))
                            .foregroundColor(palette.selectedInteractionBarItem)
                            .frame(width: iconWidth)
                            .padding(.horizontal, iconWidth)
                    }
                }
                .accessibilityHidden(true) // prevent these from popping up in VO
                .opacity(dragState == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
            }
    }
    
    private func draggingUpdated() {
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
                    leadingSwipeSymbol = primaryLeadingAction?.swipeIcon1
                    dragBackground = primaryLeadingAction?.color.opacity(dragPosition / threshold)
                } else {
                    leadingSwipeSymbol = action?.swipeIcon2
                    dragBackground = action?.color.opacity(dragPosition / threshold)
                }
            case .trailing:
                if actionIndex == nil {
                    trailingSwipeSymbol = primaryTrailingAction?.swipeIcon1
                    dragBackground = primaryTrailingAction?.color.opacity(dragPosition / threshold)
                } else {
                    trailingSwipeSymbol = action?.swipeIcon2
                    dragBackground = action?.color.opacity(dragPosition / threshold)
                }
            }
            
            // If crossed an edge, play a gentle haptic
            let previousIndex = self.actionIndex(edge: edgeForActions, at: prevDragPosition)
            let currentIndex = self.actionIndex(edge: edgeForActions, at: dragPosition)
            if let hapticInfo = hapticInfo(transitioningFrom: previousIndex, to: currentIndex) {
                HapticManager.main.play(haptic: hapticInfo.0, priority: hapticInfo.1)
            }
                          
            prevDragPosition = dragPosition
        }
    }
    
    private func draggingDidEnd() {
        let finalDragPosition = prevDragPosition
        
        reset()
        
        let action = swipeAction(at: finalDragPosition)
        
        if let action = action as? BasicAction {
            action.callbackWithConfirmation(navigation: navigation)
        } else if let action = action as? ShareAction {
            navigation.shareUrl = action.url
        } else if let action = action as? ActionGroup {
            navigation.showPopup(action)
        }
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.25)) {
            dragPosition = .zero
            prevDragPosition = .zero
            leadingSwipeSymbol = primaryLeadingAction?.swipeIcon1
            trailingSwipeSymbol = primaryTrailingAction?.swipeIcon1
            dragBackground = palette.background
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
    private func swipeAction(at dragPosition: CGFloat) -> (any Action)? {
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
        let thresholdIndex = config.behavior.thresholds.lastIndex {
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
                print(#function, "leading action not configured for this threshold")
                return config.leadingActions.endIndex - 1
            }
            return thresholdIndex
        case .trailing:
            if thresholdIndex > (config.trailingActions.endIndex - 1) {
                print(#function, "trailing action not configured for this threshold")
                return config.trailingActions.endIndex - 1
            }
            return thresholdIndex
        }
    }
    
    /// Get the action associated with an edge at the specified index.
    private func action(edge: HorizontalEdge, index actionIndex: Array<CGFloat>.Index?) -> (any Action)? {
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
    ) -> (Haptic, HapticPriority)? {
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
                return config.behavior.primaryThreshold
            case .trailing:
                return -config.behavior.primaryThreshold
            }
        }
        
        switch edgeForActions {
        case .leading:
            return config.behavior.thresholds[actionIndex]
        case .trailing:
            return -config.behavior.thresholds[actionIndex]
        }
    }
}

extension View {
    /// Adds quick swipes to a view.
    ///
    /// NOTE: if the view you are attaching this to also has a context menu, add the context menu view modifier AFTER the quick swipes modifier! This will prevent the quick swipe from triggering and appearing bugged on an aborted context menu pop if the context menu animation initiates.
    /// - Parameters:
    ///   - leading: leading edge quick swipes, ordered by ascending swipe distance from leading edge
    ///   - trailing: trailing edge quick swipes, ordered by ascending swipe distance from leading edge
    @ViewBuilder
    func quickSwipes(
        leading: [any Action] = [],
        trailing: [any Action] = [],
        dragThresholds: SwipeBehavior = .standard
    ) -> some View {
        modifier(
            QuickSwipeView(
                config: .init(
                    leadingActions: leading,
                    trailingActions: trailing
                )
            )
        )
    }
    
    @ViewBuilder
    func quickSwipes(_ config: SwipeConfiguration) -> some View {
        modifier(
            QuickSwipeView(config: config)
        )
    }
}
