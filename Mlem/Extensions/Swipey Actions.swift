//
//  Swipey Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

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

struct SwipeyView: ViewModifier {
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color? = .systemBackground
    @State var leadingSwipeSymbol: String?
    @State var trailingSwipeSymbol: String?

    // isDragging callback
    @Binding var isDragging: Bool
    
    let primaryLeadingAction: SwipeAction?
    let secondaryLeadingAction: SwipeAction?
    let primaryTrailingAction: SwipeAction?
    let secondaryTrailingAction: SwipeAction?
    
    init(isDragging: Binding<Bool>,
         primaryLeadingAction: SwipeAction?,
         secondaryLeadingAction: SwipeAction?,
         primaryTrailingAction: SwipeAction?,
         secondaryTrailingAction: SwipeAction?
    ) {
        // assert that no secondary action exists without a primary action
        // this is logically equivalent to (primaryAction == nil -> secondaryAction == nil)
        assert(
            primaryLeadingAction != nil || secondaryLeadingAction == nil,
            "No secondary action \(secondaryLeadingAction != nil) should be present without a primary \(primaryLeadingAction == nil)"
        )
        
        assert(
            primaryTrailingAction != nil || secondaryTrailingAction == nil,
            "No secondary action should be present without a primary"
        )
        
        self.primaryLeadingAction = primaryLeadingAction
        self.secondaryLeadingAction = secondaryLeadingAction
        self.primaryTrailingAction = primaryTrailingAction
        self.secondaryTrailingAction = secondaryTrailingAction
        
        // other init
        _leadingSwipeSymbol = State(initialValue: primaryLeadingAction?.symbol.fillName)
        _trailingSwipeSymbol = State(initialValue: primaryTrailingAction?.symbol.fillName)
        _isDragging = isDragging
    }
    
    // swiftlint:disable cyclomatic_complexity
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
                }
            }
            .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
        // needs to be high priority or else dragging on links leads to navigating to the link at conclusion of drag
            .highPriorityGesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
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
                    
                    // update color and symbol. If crossed an edge, play a gentle haptic
                    if dragPosition < -1 * AppConstants.longSwipeDragMin {
                        trailingSwipeSymbol = secondaryTrailingAction?.symbol.fillName ?? primaryTrailingAction?.symbol.fillName
                        dragBackground = secondaryTrailingAction?.color ?? primaryTrailingAction?.color
                        if prevDragPosition >= -1 * AppConstants.longSwipeDragMin, secondaryLeadingAction != nil {
                            HapticManager.shared.gentleInfo()
                        }
                    } else if dragPosition < -1 * AppConstants.shortSwipeDragMin {
                        trailingSwipeSymbol = primaryTrailingAction?.symbol.fillName
                        dragBackground = primaryTrailingAction?.color
                        if prevDragPosition >= -1 * AppConstants.shortSwipeDragMin {
                            HapticManager.shared.gentleInfo()
                        }
                    } else if dragPosition < 0 {
                        trailingSwipeSymbol = primaryTrailingAction?.symbol.emptyName
                        dragBackground = primaryTrailingAction?.color.opacity(-1 * dragPosition / AppConstants.shortSwipeDragMin)
                    } else if dragPosition < AppConstants.shortSwipeDragMin {
                        leadingSwipeSymbol = primaryLeadingAction?.symbol.emptyName
                        dragBackground = primaryLeadingAction?.color.opacity(dragPosition / AppConstants.shortSwipeDragMin)
                    } else if dragPosition < AppConstants.longSwipeDragMin {
                        leadingSwipeSymbol = primaryLeadingAction?.symbol.fillName
                        dragBackground = primaryLeadingAction?.color
                        if prevDragPosition <= AppConstants.shortSwipeDragMin {
                            HapticManager.shared.gentleInfo()
                        }
                    } else {
                        leadingSwipeSymbol = secondaryLeadingAction?.symbol.fillName ?? primaryLeadingAction?.symbol.fillName
                        dragBackground = secondaryLeadingAction?.color ?? primaryLeadingAction?.color
                        if prevDragPosition <= AppConstants.longSwipeDragMin, secondaryLeadingAction != nil {
                            HapticManager.shared.gentleInfo()
                        }
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
            if finalDragPosition < -1 * AppConstants.longSwipeDragMin {
                Task(priority: .userInitiated) {
                    let action = secondaryTrailingAction ?? primaryTrailingAction
                    await action?.action()
                }
            } else if finalDragPosition < -1 * AppConstants.shortSwipeDragMin {
                Task(priority: .userInitiated) {
                    await primaryTrailingAction?.action()
                }
            } else if finalDragPosition > AppConstants.longSwipeDragMin {
                Task(priority: .userInitiated) {
                    let action = secondaryLeadingAction ?? primaryLeadingAction
                    await action?.action()
                }
            } else if finalDragPosition > AppConstants.shortSwipeDragMin {
                Task(priority: .userInitiated) {
                    await primaryLeadingAction?.action()
                }
            }
        }
    }
    
    private func reset() {
        withAnimation(.spring(response: 0.3)) {
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
}
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable function_body_length

extension View {
    @ViewBuilder
    func addSwipeyActions(isDragging: Binding<Bool>,
                          primaryLeadingAction: SwipeAction?,
                          secondaryLeadingAction: SwipeAction?,
                          primaryTrailingAction: SwipeAction?,
                          secondaryTrailingAction: SwipeAction?
    ) -> some View {
        modifier(
            SwipeyView(
                isDragging: isDragging,
                primaryLeadingAction: primaryLeadingAction,
                secondaryLeadingAction: secondaryLeadingAction,
                primaryTrailingAction: primaryTrailingAction,
                secondaryTrailingAction: secondaryTrailingAction
            )
        )
    }
}
