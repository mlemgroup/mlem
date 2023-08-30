//
//  Swipey Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import Dependencies
import SwiftUI

struct SwipeAction {
    struct Symbol {
        let emptyName: String
        let fillName: String
    }
    
    let symbol: Symbol
    let color: Color
    let action: () async -> Void
}

struct SwipeConfiguration {
    /// In ascending order of appearance.
    let leadingActions: [SwipeAction]
    /// In ascending order of appearance.
    let trailingActions: [SwipeAction]
    
    init(leadingActions: [SwipeAction?], trailingActions: [SwipeAction?]) {
        self.leadingActions = leadingActions.compactMap { $0 }
        self.trailingActions = trailingActions.compactMap { $0 }
    }
}

struct SwipeyView: ViewModifier {
    @Dependency(\.hapticManager) var hapticManager
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color? = .systemBackground
    @State var leadingSwipeSymbol: String?
    @State var trailingSwipeSymbol: String?
    
    private var primaryLeadingAction: SwipeAction? { actions.leadingActions.first }
    private var primaryTrailingAction: SwipeAction? { actions.trailingActions.first }
    
    let actions: SwipeConfiguration
    
    init(configuration: SwipeConfiguration) {
        self.actions = configuration
        
        _leadingSwipeSymbol = State(initialValue: primaryLeadingAction?.symbol.fillName)
        _trailingSwipeSymbol = State(initialValue: primaryTrailingAction?.symbol.fillName)
    }
    
    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        content
            // add a little shadow under the edge
            .background {
                GeometryReader { proxy in
                    Rectangle()
                        .foregroundColor(.clear)
                        .border(width: 10, edges: [.leading, .trailing], color: .black)
                        .shadow(radius: 5)
                        .mask(Rectangle().frame(width: proxy.size.width + 20)) // clip top/bottom
                        .opacity(dragState == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
                }
            }
            .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
            // needs to be high priority or else dragging on links leads to navigating to the link at conclusion of drag
            .highPriorityGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
                    .updating($dragState) { value, state, _ in
                        // this check adds a dead zone to the left side of the screen so it doesn't interfere with navigation
                        if dragState != .zero || value.location.x > 70 {
                            state = value.translation.width
                        }
                    }
            )
            .onChange(of: dragState) { newDragState in
                // if dragState changes and is now 0, gesture has ended; compute action based on last detected position
                if newDragState == .zero {
                    draggingDidEnd()
                } else {
                    guard shouldRespondToDragPosition(newDragState) else {
                        // as swipe actions are optional we don't allow dragging without a primary action
                        return
                    }
                    
                    // update position
                    dragPosition = newDragState
                    
                    let edgeForActions = self.edgeForActions(at: dragPosition)
                    let actionIndex = self.actionIndex(edge: edgeForActions, at: dragPosition)
                    let action = self.action(edge: edgeForActions, index: actionIndex)
                    let threshold = self.actionThreshold(edge: edgeForActions, index: actionIndex)
                    
                    // update color and symbol. If crossed an edge, play a gentle haptic
                    switch edgeForActions {
                    case .leading:
                        leadingSwipeSymbol = actionIndex == nil 
                        ? primaryLeadingAction?.symbol.emptyName
                        : action?.symbol.fillName
                        
                        dragBackground = actionIndex == nil
                        ? primaryLeadingAction?.color.opacity(dragPosition / threshold)
                        : action?.color.opacity(dragPosition / threshold)
                    case .trailing:
                        trailingSwipeSymbol = actionIndex == nil
                        ? primaryTrailingAction?.symbol.emptyName
                        : action?.symbol.fillName
                        
                        dragBackground = actionIndex == nil
                        ? primaryTrailingAction?.color.opacity(dragPosition / threshold)
                        : action?.color.opacity(dragPosition / threshold)
                    }
                    
                    // If crossed an edge, play a gentle haptic
                    let previousIndex = self.actionIndex(edge: edgeForActions, at: prevDragPosition)
                    let currentIndex = self.actionIndex(edge: edgeForActions, at: dragPosition)
                    if let hapticInfo = self.hapticInfo(transitioningFrom: previousIndex, to: currentIndex) {
                        hapticManager.play(haptic: hapticInfo.0, priority: hapticInfo.1)
                    }
                                  
                    prevDragPosition = dragPosition
                }
            }
            .background {
                dragBackground
                    .overlay {
                        HStack(spacing: 0) {
                            Image(systemName: leadingSwipeSymbol ?? "exclamationmark.triangle")
                                .font(.title)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            Spacer()
                            Image(systemName: trailingSwipeSymbol ?? "exclamationmark.triangle")
                                .font(.title)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                        }
                        .accessibilityHidden(true) // prevent these from popping up in VO
                    }
            }
            // prevents various animation glitches
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
            // disables links from highlighting when tapped
            .buttonStyle(EmptyButtonStyle())
    }
    
    private func draggingDidEnd() {
        let finalDragPosition = prevDragPosition
        
        reset()
        
        // TEMP: need to delay the call being sent because otherwise the state update cancels the animation. This should be fixed with backend support for fakers, since the vote won't change and so the animation won't stop (hopefully). This delay matches the response field of the reset() animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Task(priority: .userInitiated) {
                let action = swipeAction(at: finalDragPosition)
                await action?.action()
            }
        }
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.25)) {
            dragPosition = .zero
            prevDragPosition = .zero
            leadingSwipeSymbol = primaryLeadingAction?.symbol.emptyName
            trailingSwipeSymbol = primaryTrailingAction?.symbol.emptyName
            dragBackground = .systemBackground
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
    private func swipeAction(at dragPosition: CGFloat) -> SwipeAction? {
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
        let thresholdIndex = AppConstants.swipeActionDragThresholds.lastIndex {
            switch edge {
            case .leading:
                return dragPosition > $0
            case .trailing:
                return dragPosition < -$0
            }
        }
        
        guard let thresholdIndex else {
            print(#function, "thresholdIndex == nil at this drag position")
            return nil
        }
        
        /// There may not be an associated action for a threshold.
        switch edge {
        case .leading:
            if thresholdIndex > (actions.leadingActions.endIndex - 1) {
                print(#function, "leading action not configured for this threshold")
                return actions.leadingActions.endIndex - 1
            }
            return thresholdIndex
        case .trailing:
            if thresholdIndex > (actions.trailingActions.endIndex - 1) {
                print(#function, "trailing action not configured for this threshold")
                return actions.trailingActions.endIndex - 1
            }
            return thresholdIndex
        }
    }
    
    /// Get the action associated with an edge at the specified index.
    private func action(edge: HorizontalEdge, index actionIndex: Array<CGFloat>.Index?) -> SwipeAction? {
        guard let actionIndex else {
            return nil
        }
        switch edge {
        case .leading:
            return actions.leadingActions[safeIndex: actionIndex]
        case .trailing:
            return actions.trailingActions[safeIndex: actionIndex]
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
//        print("pIndex \(previousIndex) -> cIndex: \(currentIndex)")
        
        // Swiping towards to primary action.
        // Index values are always >= 0 for both leading/trailing edges.
        // Since nil indicates no action, we use -1 to represent nil instead (lol, yes).
        if (currentIndex ?? -1) < (previousIndex ?? -1) {
//            print("mushyInfo.low\n")
            return (.mushyInfo, .low)
        } else {
            if previousIndex == nil {
//                print("gentleInfo.high\n")
                return (.gentleInfo, .high)
            } else if previousIndex == 1 {
//                print("firmerInfo.high\n")
                return (.firmerInfo, .high)
            } else {
//                print("firmerInfo.high\n")
                return (.firmerInfo, .high)
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
                return AppConstants.shortSwipeDragMin
            case .trailing:
                return -AppConstants.shortSwipeDragMin
            }
        }
        
        switch edgeForActions {
        case .leading:
            return AppConstants.swipeActionDragThresholds[actionIndex]
        case .trailing:
            return -AppConstants.swipeActionDragThresholds[actionIndex]
        }
    }
}
// swiftlint:enable function_body_length

extension View {
    
    @ViewBuilder
    func addSwipeyActions(leading: [SwipeAction?], trailing: [SwipeAction?]) -> some View {
        modifier(
            SwipeyView(
                configuration: .init(
                    leadingActions: leading,
                    trailingActions: trailing
                )
            )
        )
    }
}
