//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import Dependencies
import SwiftUI

public struct SwipeConfiguration {
    /// In ascending order of appearance.
    let leadingActions: [BasicAction]
    /// In ascending order of appearance.
    let trailingActions: [BasicAction]
    
    let dragThresholds: DragThresholds
    
    init(
        leadingActions: [BasicAction] = [],
        trailingActions: [BasicAction] = [],
        dragThresholds: DragThresholds = .standard
    ) {
        assert(
            leadingActions.count <= 3 && trailingActions.count <= 3,
            "Too many swipe actions!"
        )
        self.leadingActions = leadingActions.compactMap { $0 }
        self.trailingActions = trailingActions.compactMap { $0 }
        self.dragThresholds = dragThresholds
    }
}

// MARK: - Drag Action Thresholds

struct DragThresholds {
    /// Minimum distance to trigger the primary action
    let primary: CGFloat
    /// Minimum distance to trigger the secondary action
    let secondary: CGFloat
    /// Minimum distance to trigger the tertiary action
    let tertiary: CGFloat
    
    var asList: [CGFloat] { [primary, secondary, tertiary] }
    
    static let standard: DragThresholds = .init(
        primary: 60,
        secondary: 150,
        tertiary: 240
    )
    
    static let compact: DragThresholds = .init(
        primary: 30,
        secondary: 75,
        tertiary: 120
    )
}

// MARK: -

struct QuickSwipeView: ViewModifier {
    @Environment(Palette.self) var palette
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color? = Palette.main.background
    @State var iconColor: Color? = .white
    @State var leadingSwipeSymbol: String?
    @State var trailingSwipeSymbol: String?
    
    private var primaryLeadingAction: BasicAction? { actions.leadingActions.first }
    private var primaryTrailingAction: BasicAction? { actions.trailingActions.first }
    
    let actions: SwipeConfiguration
    
    init(configuration: SwipeConfiguration) {
        self.actions = configuration
        
        _leadingSwipeSymbol = State(initialValue: primaryLeadingAction?.swipeIcon1)
        _trailingSwipeSymbol = State(initialValue: primaryTrailingAction?.swipeIcon1)
    }
    
    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        ScrollView(.horizontal) {
            content
        }
//            // add a little shadow under the edge
//            .background {
//                Rectangle()
//                    .foregroundStyle(.clear)
//                    .border(width: 10, edges: [.leading, .trailing], color: .black)
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    .shadow(radius: 5)
//                    .opacity(dragState == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
//                // .clipShape(RoundedRectangle(cornerRadius: 16))
        ////                GeometryReader { proxy in
        ////                    Rectangle()
        ////                        .foregroundColor(.clear)
        ////                        .border(width: 10, edges: [.leading, .trailing], color: .black)
        ////                        .shadow(radius: 5)
        ////                        .mask(RoundedRectangle(cornerRadius: 16).frame(width: proxy.size.width + 20)) // clip top/bottom
        ////                        // .clipShape(RoundedRectangle(cornerRadius: 16))
        ////                        .opacity(dragState == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
        ////                }
//            }
//            .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
//            // needs to be high priority or else dragging on links leads to navigating to the link at conclusion of drag
//            .highPriorityGesture(
//                DragGesture(minimumDistance: 20, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
//                    .updating($dragState) { value, state, _ in
//                        // this check adds a dead zone to the left side of the screen so it doesn't interfere with navigation
//                        if dragState == .zero && abs(value.translation.height) * 1.7 > abs(value.translation.width) {
//                            return
//                        }
//                        if dragState != .zero || value.location.x > 70 {
//                            state = value.translation.width
//                        }
//                    }
//            )
//            .onChange(of: dragState) {
//                // if dragState changes and is now 0, gesture has ended; compute action based on last detected position
//                if dragState == .zero {
//                    draggingDidEnd()
//                } else {
//                    guard shouldRespondToDragPosition(dragState) else {
//                        // as swipe actions are optional we don't allow dragging without a primary action
//                        return
//                    }
//
//                    // update position
//                    dragPosition = dragState
//
//                    let edgeForActions = edgeForActions(at: dragPosition)
//                    let actionIndex = actionIndex(edge: edgeForActions, at: dragPosition)
//                    let action = action(edge: edgeForActions, index: actionIndex)
//                    let threshold = actionThreshold(edge: edgeForActions, index: actionIndex)
//
//                    // update color and symbol. If crossed an edge, play a gentle haptic
//                    switch edgeForActions {
//                    case .leading:
//                        if actionIndex == nil {
//                            leadingSwipeSymbol = primaryLeadingAction?.swipeIcon1
//                            dragBackground = primaryLeadingAction?.color.opacity(dragPosition / threshold)
//                            iconColor = nil
//                        } else {
//                            leadingSwipeSymbol = action?.swipeIcon2
//                            dragBackground = action?.color.opacity(dragPosition / threshold)
//                            iconColor = nil
//                        }
//                    case .trailing:
//                        if actionIndex == nil {
//                            trailingSwipeSymbol = primaryTrailingAction?.swipeIcon1
//                            dragBackground = primaryTrailingAction?.color.opacity(dragPosition / threshold)
//                            iconColor = nil
//                        } else {
//                            trailingSwipeSymbol = action?.swipeIcon2
//                            dragBackground = action?.color.opacity(dragPosition / threshold)
//                            iconColor = nil
//                        }
//                    }
//
//                    // If crossed an edge, play a gentle haptic
//                    let previousIndex = self.actionIndex(edge: edgeForActions, at: prevDragPosition)
//                    let currentIndex = self.actionIndex(edge: edgeForActions, at: dragPosition)
//                    if let hapticInfo = hapticInfo(transitioningFrom: previousIndex, to: currentIndex) {
//                        HapticManager.main.play(haptic: hapticInfo.0, priority: hapticInfo.1)
//                    }
//
//                    prevDragPosition = dragPosition
//                }
//            }
//            .background {
//                dragBackground
//                    .overlay {
//                        HStack(spacing: 0) {
//                            Image(systemName: leadingSwipeSymbol ?? Icons.warning)
//                                .font(.title)
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 20)
//                            Spacer()
//                            Image(systemName: trailingSwipeSymbol ?? Icons.warning)
//                                .font(.title)
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(iconColor ?? .white)
//                                .padding(.horizontal, 20)
//                        }
//                        .accessibilityHidden(true) // prevent these from popping up in VO
//                        .opacity(dragState == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
//                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//            }
//            // prevents various animation glitches
//            .transaction { transaction in
//                transaction.disablesAnimations = true
//            }
//            // disables links from highlighting when tapped
//            .buttonStyle(EmptyButtonStyle())
//            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func draggingDidEnd() {
        let finalDragPosition = prevDragPosition
        
        reset()
        
        swipeAction(at: finalDragPosition)?.callback?()
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.25)) {
            dragPosition = .zero
            prevDragPosition = .zero
            leadingSwipeSymbol = primaryLeadingAction?.swipeIcon1
            trailingSwipeSymbol = primaryTrailingAction?.swipeIcon1
            dragBackground = palette.background
            iconColor = .white
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
    private func swipeAction(at dragPosition: CGFloat) -> BasicAction? {
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
        let thresholdIndex = actions.dragThresholds.asList.lastIndex {
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
    private func action(edge: HorizontalEdge, index actionIndex: Array<CGFloat>.Index?) -> BasicAction? {
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
                return actions.dragThresholds.primary
            case .trailing:
                return -actions.dragThresholds.primary
            }
        }
        
        switch edgeForActions {
        case .leading:
            return actions.dragThresholds.asList[actionIndex]
        case .trailing:
            return -actions.dragThresholds.asList[actionIndex]
        }
    }
}

// swiftlint:enable function_body_length

extension View {
    /// Adds quick swipes to a view.
    ///
    /// NOTE: if the view you are attaching this to also has a context menu, add the context menu view modifier AFTER the quick swipes modifier! This will prevent the quick swipe from triggering and appearing bugged on an aborted context menu pop if the context menu animation initiates.
    /// - Parameters:
    ///   - leading: leading edge quick swipes, ordered by ascending swipe distance from leading edge
    ///   - trailing: trailing edge quick swipes, ordered by ascending swipe distance from leading edge
    @ViewBuilder
    func quickSwipes(
        leading: [BasicAction] = [],
        trailing: [BasicAction] = [],
        dragThresholds: DragThresholds = .standard
    ) -> some View {
        modifier(
            QuickSwipeView(
                configuration: .init(
                    leadingActions: leading,
                    trailingActions: trailing
                )
            )
        )
    }
    
    @ViewBuilder
    func quickSwipes(_ configuration: SwipeConfiguration) -> some View {
        modifier(
            QuickSwipeView(configuration: configuration)
        )
    }
}
