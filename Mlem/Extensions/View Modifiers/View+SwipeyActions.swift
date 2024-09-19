//
//  View+SwipeyActions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

// swiftlint:disable file_length

import Dependencies
import SwiftUI

// MARK: -

public struct SwipeAction {
    struct Symbol {
        let emptyName: String
        let fillName: String
    }
    
    let symbol: Symbol
    let color: Color
    let iconColor: Color?
    let action: () -> Void
    
    init(symbol: Symbol, color: Color, iconColor: Color? = nil, action: @escaping () -> Void) {
        self.symbol = symbol
        self.color = color
        self.iconColor = iconColor
        self.action = action
    }
}

// MARK: -

public struct SwipeConfiguration {
    /// In ascending order of appearance.
    let leadingActions: [SwipeAction]
    /// In ascending order of appearance.
    let trailingActions: [SwipeAction]
    
    init(leadingActions: [SwipeAction?] = [], trailingActions: [SwipeAction?] = []) {
        assert(
            leadingActions.count <= 3 && trailingActions.count <= 3,
            "Getting a little swipey aren't we? Ask your fellow Mlem'ers if you really need more than 3 swipe actions =)"
        )
        self.leadingActions = leadingActions.compactMap { $0 }
        self.trailingActions = trailingActions.compactMap { $0 }
    }
}

// MARK: - Drag Action Thresholds

public extension SwipeConfiguration {
    /// Users and programmers can declare a custom set of drag thresholds in order of appearance (see `defaults`).
    /// - Thresholds are magnitude-only along a given axis: Consumers should use negative values for leading actions.
    enum DragThresholds {
        /// User's preferred set of drag thresholds.
        static var userPreferred: [CGFloat] {
            /// - NOTE: Currently not yet user customizable. [2023.08]
            defaults
        }
        
        /// Convenience.
        static var shortSwipe: CGFloat {
            userPreferred.first ?? shortSwipeDragMin
        }
        
        /// Mlem defaults.
        /// - To support more actions, simply add more drag thresholds.
        private static let defaults: [CGFloat] = [
            Self.shortSwipeDragMin,
            Self.longSwipeDragMin,
            Self.tertiarySwipeDragMin
        ]
        
        private static let shortSwipeDragMin: CGFloat = 60
        private static let longSwipeDragMin: CGFloat = 150
        private static let tertiarySwipeDragMin: CGFloat = 240
    }
}

// MARK: -

struct SwipeyView: ViewModifier {
    @Dependency(\.hapticManager) var hapticManager
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color? = .systemBackground
    @State var iconColor: Color? = .white
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
    
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 18.0, *) {
                iOS18Body(content: content)
            } else {
                legacyBody(content: content)
                    .onChange(of: dragState) { newDragState in
                        draggingUpdated(dragState: newDragState)
                    }
            }
        }
        // add a little shadow under the edge
        .background {
            GeometryReader { proxy in
                Rectangle()
                    .foregroundColor(.clear)
                    .border(width: 10, edges: [.leading, .trailing], color: .black)
                    .shadow(radius: 5)
                    .mask(Rectangle().frame(width: proxy.size.width + 20)) // clip top/bottom
                    .opacity(dragPosition == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
            }
        }
        .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
        .background {
            iconBackground
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
    func legacyBody(content: Content) -> some View {
        content
            // needs to be high priority or else dragging on links leads to navigating to the link at conclusion of drag
            .highPriorityGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
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
            // prevents various animation glitches
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
    
    @available(iOS 18.0, *) @ViewBuilder
    func iOS18Body(content: Content) -> some View {
        content
            .geometryGroup()
            .gesture(
                PanGesture { recognizer in
                    if recognizer.state == .ended {
                        draggingUpdated(dragState: 0)
                    } else {
                        draggingUpdated(dragState: recognizer.translation(in: recognizer.view).x)
                    }
                }
            )
    }
    
    var iconBackground: some View {
        dragBackground
            .overlay {
                HStack(spacing: 0) {
                    if dragPosition > 0 {
                        Image(systemName: leadingSwipeSymbol ?? Icons.warning)
                            .font(.title)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    }
                    Spacer()
                    if dragPosition < 0 {
                        Image(systemName: trailingSwipeSymbol ?? Icons.warning)
                            .font(.title)
                            .frame(width: 20, height: 20)
                            .foregroundColor(iconColor ?? .white)
                            .padding(.horizontal, 20)
                    }
                }
                .accessibilityHidden(true) // prevent these from popping up in VO
                .opacity(dragPosition == .zero ? 0 : 1) // prevent this view from appearing in animations on parent view(s).
            }
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
                    leadingSwipeSymbol = primaryLeadingAction?.symbol.emptyName
                    dragBackground = primaryLeadingAction?.color.opacity(dragPosition / threshold)
                    iconColor = primaryLeadingAction?.iconColor
                } else {
                    leadingSwipeSymbol = action?.symbol.fillName
                    dragBackground = action?.color.opacity(dragPosition / threshold)
                    iconColor = action?.iconColor
                }
            case .trailing:
                if actionIndex == nil {
                    trailingSwipeSymbol = primaryTrailingAction?.symbol.emptyName
                    dragBackground = primaryTrailingAction?.color.opacity(dragPosition / threshold)
                    iconColor = primaryTrailingAction?.iconColor
                } else {
                    trailingSwipeSymbol = action?.symbol.fillName
                    dragBackground = action?.color.opacity(dragPosition / threshold)
                    iconColor = action?.iconColor
                }
            }
            
            // If crossed an edge, play a gentle haptic
            let previousIndex = self.actionIndex(edge: edgeForActions, at: prevDragPosition)
            let currentIndex = self.actionIndex(edge: edgeForActions, at: dragPosition)
            if let hapticInfo = hapticInfo(transitioningFrom: previousIndex, to: currentIndex) {
                hapticManager.play(haptic: hapticInfo.0, priority: hapticInfo.1)
            }
                          
            prevDragPosition = dragPosition
        }
    }
    
    private func draggingDidEnd() {
        let finalDragPosition = prevDragPosition
        
        reset()
        
        swipeAction(at: finalDragPosition)?.action()
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.25)) {
            dragPosition = .zero
            prevDragPosition = .zero
            leadingSwipeSymbol = primaryLeadingAction?.symbol.emptyName
            trailingSwipeSymbol = primaryTrailingAction?.symbol.emptyName
            dragBackground = .systemBackground
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
        let thresholdIndex = SwipeConfiguration.DragThresholds.userPreferred.lastIndex {
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
                return SwipeConfiguration.DragThresholds.shortSwipe
            case .trailing:
                return -SwipeConfiguration.DragThresholds.shortSwipe
            }
        }
        
        switch edgeForActions {
        case .leading:
            return SwipeConfiguration.DragThresholds.userPreferred[actionIndex]
        case .trailing:
            return -SwipeConfiguration.DragThresholds.userPreferred[actionIndex]
        }
    }
}

extension View {
    /// Adds swipey actions to a view.
    ///
    /// NOTE: if the view you are attaching this to also has a context menu, add the context menu view modifier AFTER the swipey actions modifier! This will prevent the swipey action from triggering and appearing bugged on an aborted context menu pop if the context menu animation initiates.
    /// - Parameters:
    ///   - leading: leading edge swipey actions, ordered by ascending swipe distance from leading edge
    ///   - trailing: trailing edge swipey actions, ordered by ascending swipe distance from leading edge
    @ViewBuilder
    func addSwipeyActions(leading: [SwipeAction?] = [], trailing: [SwipeAction?] = []) -> some View {
        modifier(
            SwipeyView(
                configuration: .init(
                    leadingActions: leading,
                    trailingActions: trailing
                )
            )
        )
    }
    
    @ViewBuilder
    func addSwipeyActions(_ configuration: SwipeConfiguration) -> some View {
        modifier(
            SwipeyView(configuration: configuration)
        )
    }
}

// swiftlint:enable file_length
