//
//  Swipey Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct SwipeAction {
    let symbolName: String
    let colour: Color
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

    // haptics
    let tapper: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    // isDragging callback
    @Binding var isDragging: Bool
    
    let primaryLeadingAction: SwipeAction?
    let secondaryLeadingAction: SwipeAction?
    let primaryTrailingAction: SwipeAction?
    let secondaryTrailingAction: SwipeAction?

    // symbols
    let emptyLeadingSymbolName: String
    let emptyTrailingSymbolName: String

    init(isDragging: Binding<Bool>,
         emptyLeadingSymbolName: String,
         primaryLeadingAction: SwipeAction?,
         secondaryLeadingAction: SwipeAction?,
         emptyTrailingSymbolName: String,
         primaryTrailingAction: SwipeAction?,
         secondaryTrailingAction: SwipeAction?
    ) {
        self.emptyLeadingSymbolName = emptyLeadingSymbolName
        self.primaryLeadingAction = primaryLeadingAction
        self.secondaryLeadingAction = secondaryLeadingAction
        self.emptyTrailingSymbolName = emptyTrailingSymbolName
        self.primaryTrailingAction = primaryTrailingAction
        self.secondaryTrailingAction = secondaryTrailingAction

        // other init
        _leadingSwipeSymbol = State(initialValue: primaryLeadingAction?.symbolName)
        _trailingSwipeSymbol = State(initialValue: primaryTrailingAction?.symbolName)
        _isDragging = isDragging
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        ZStack {
            // background
            dragBackground

            // symbols
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

            // content
            content
                .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
                .highPriorityGesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
                        .updating($dragState) { value, state, _ in
                            // this check adds a dead zone to the left side of the screen so it doesn't interfere with navigation
                            if dragState != .zero || value.location.x > 50 {
                                state = value.translation.width
                            }
                        }
                )
                .onChange(of: dragState) { newDragState in
                    // if dragState changes and is now 0, gesture has ended; compute action based on last detected position
                    if newDragState == .zero {
                        draggingDidEnd()
                    } else {
                        // update position
                        dragPosition = newDragState

                        // update color and symbol. If crossed an edge, play a gentle haptic
                        if dragPosition < -1 * AppConstants.longSwipeDragMin {
                            trailingSwipeSymbol = secondaryTrailingAction?.symbolName ?? primaryTrailingAction?.symbolName
                            dragBackground = secondaryTrailingAction?.colour ?? primaryTrailingAction?.colour
                            if prevDragPosition >= -1 * AppConstants.longSwipeDragMin, secondaryLeadingAction != nil {
                                tapper.impactOccurred()
                            }
                        } else if dragPosition < -1 * AppConstants.shortSwipeDragMin {
                            trailingSwipeSymbol = primaryTrailingAction?.symbolName
                            dragBackground = primaryTrailingAction?.colour
                            if prevDragPosition >= -1 * AppConstants.shortSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        } else if dragPosition < 0 {
                            trailingSwipeSymbol = emptyTrailingSymbolName
                            dragBackground = primaryTrailingAction?.colour.opacity(-1 * dragPosition / AppConstants.shortSwipeDragMin)
                        } else if dragPosition < AppConstants.shortSwipeDragMin {
                            leadingSwipeSymbol = emptyLeadingSymbolName
                            dragBackground = primaryLeadingAction?.colour.opacity(dragPosition / AppConstants.shortSwipeDragMin)
                        } else if dragPosition < AppConstants.longSwipeDragMin {
                            leadingSwipeSymbol = primaryLeadingAction?.symbolName
                            dragBackground = primaryLeadingAction?.colour
                            if prevDragPosition <= AppConstants.shortSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        } else {
                            leadingSwipeSymbol = secondaryLeadingAction?.symbolName ?? primaryLeadingAction?.symbolName
                            dragBackground = secondaryLeadingAction?.colour ?? primaryLeadingAction?.colour
                            if prevDragPosition <= AppConstants.longSwipeDragMin, secondaryLeadingAction != nil {
                                tapper.impactOccurred()
                            }
                        }
                        prevDragPosition = dragPosition
                    }
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
        // TODO: instant upvote feedback (waiting on backend)
        if prevDragPosition < -1 * AppConstants.longSwipeDragMin {
            Task(priority: .userInitiated) {
                let action = secondaryTrailingAction ?? primaryTrailingAction
                await action?.action()
            }
        } else if prevDragPosition < -1 * AppConstants.shortSwipeDragMin {
            Task(priority: .userInitiated) {
                await primaryTrailingAction?.action()
            }
        } else if prevDragPosition > AppConstants.longSwipeDragMin {
            Task(priority: .userInitiated) {
                let action = secondaryLeadingAction ?? primaryLeadingAction
                await action?.action()
            }
        } else if prevDragPosition > AppConstants.shortSwipeDragMin {
            Task(priority: .userInitiated) {
                await primaryLeadingAction?.action()
            }
        }
        
        reset()
    }
    
    private func reset() {
        withAnimation(.interactiveSpring()) {
            dragPosition = .zero
            leadingSwipeSymbol = emptyLeadingSymbolName
            trailingSwipeSymbol = emptyTrailingSymbolName
            dragBackground = .systemBackground
        }
    }
}
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable function_body_length

extension View {
    @ViewBuilder
    // swiftlint:disable function_parameter_count
    func addSwipeyActions(isDragging: Binding<Bool>,
                          emptyLeadingSymbolName: String,
                          primaryLeadingAction: SwipeAction?,
                          secondaryLeadingAction: SwipeAction?,
                          emptyTrailingSymbolName: String,
                          primaryTrailingAction: SwipeAction?,
                          secondaryTrailingAction: SwipeAction?
    ) -> some View {
        modifier(
            SwipeyView(
                isDragging: isDragging,
                emptyLeadingSymbolName: emptyLeadingSymbolName,
                primaryLeadingAction: primaryLeadingAction,
                secondaryLeadingAction: secondaryLeadingAction,
                emptyTrailingSymbolName: emptyTrailingSymbolName,
                primaryTrailingAction: primaryTrailingAction,
                secondaryTrailingAction: secondaryTrailingAction
            )
        )
    }
    // swiftlint:enable function_parameter_count
}
