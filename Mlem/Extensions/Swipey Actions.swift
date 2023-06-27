//
//  Swipey Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct SwipeyView: ViewModifier {
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition = CGFloat.zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color = .systemBackground
    @State var leftSwipeSymbol: String
    @State var rightSwipeSymbol: String

    // haptics
    let tapper: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    // isDragging callback
    @Binding var isDragging: Bool

    // callbacks
    let shortLeftAction: () async -> Void
    let longLeftAction: () async -> Void
    let shortRightAction: () async -> Void
    let longRightAction: () async -> Void

    // symbols
    let emptyLeftSymbolName: String
    let shortLeftSymbolName: String
    let longLeftSymbolName: String
    let emptyRightSymbolName: String
    let shortRightSymbolName: String
    let longRightSymbolName: String

    // colors
    let shortLeftColor: Color
    let longLeftColor: Color
    let shortRightColor: Color
    let longRightColor: Color

    // TODO: compress this somehow? This is *awful* to read
    init(isDragging: Binding<Bool>,

         emptyLeftSymbolName: String,
         shortLeftSymbolName: String,
         shortLeftAction: @escaping () async -> Void,
         shortLeftColor: Color,

         longLeftSymbolName: String,
         longLeftAction: @escaping () async -> Void,
         longLeftColor: Color,

         emptyRightSymbolName: String,
         shortRightSymbolName: String,
         shortRightAction: @escaping () async -> Void,
         shortRightColor: Color,

         longRightSymbolName: String,
         longRightAction: @escaping () async -> Void,
         longRightColor: Color) {
        // callbacks
        self.shortLeftAction = shortLeftAction
        self.longLeftAction = longLeftAction
        self.shortRightAction = shortRightAction
        self.longRightAction = longRightAction

        // symbols
        self.emptyLeftSymbolName = emptyLeftSymbolName
        self.shortLeftSymbolName = shortLeftSymbolName
        self.longLeftSymbolName = longLeftSymbolName
        self.emptyRightSymbolName = emptyRightSymbolName
        self.shortRightSymbolName = shortRightSymbolName
        self.longRightSymbolName = longRightSymbolName

        // colors
        self.shortLeftColor = shortLeftColor
        self.longLeftColor = longLeftColor
        self.shortRightColor = shortRightColor
        self.longRightColor = longRightColor

        // other init
        _leftSwipeSymbol = State(initialValue: shortLeftSymbolName)
        _rightSwipeSymbol = State(initialValue: shortRightSymbolName)
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
                Image(systemName: leftSwipeSymbol)
                    .font(.title)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                Spacer()
                Image(systemName: rightSwipeSymbol)
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
                        // TODO: instant upvote feedback (waiting on backend)
                        if prevDragPosition < -1 * AppConstants.longSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await longRightAction()
                            }
                        } else if prevDragPosition < -1 * AppConstants.shortSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await shortRightAction()
                            }
                        } else if prevDragPosition > AppConstants.longSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await longLeftAction()
                            }
                        } else if prevDragPosition > AppConstants.shortSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await shortLeftAction()
                            }
                        }
                        // bounce back to neutral
                        withAnimation(.interactiveSpring()) {
                            dragPosition = .zero
                            leftSwipeSymbol = emptyLeftSymbolName
                            rightSwipeSymbol = emptyRightSymbolName
                            dragBackground = .systemBackground
                        }
                    } else {
                        // update position
                        dragPosition = newDragState

                        // update color and symbol. If crossed an edge, play a gentle haptic
                        if dragPosition < -1 * AppConstants.longSwipeDragMin {
                            rightSwipeSymbol = longRightSymbolName
                            dragBackground = longRightColor
                            if prevDragPosition >= -1 * AppConstants.longSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        } else if dragPosition < -1 * AppConstants.shortSwipeDragMin {
                            rightSwipeSymbol = shortRightSymbolName
                            dragBackground = shortRightColor
                            if prevDragPosition >= -1 * AppConstants.shortSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        } else if dragPosition < 0 {
                            rightSwipeSymbol = emptyRightSymbolName
                            dragBackground = shortRightColor.opacity(-1 * dragPosition / AppConstants.shortSwipeDragMin)
                        } else if dragPosition < AppConstants.shortSwipeDragMin {
                            leftSwipeSymbol = emptyLeftSymbolName
                            dragBackground = shortLeftColor.opacity(dragPosition / AppConstants.shortSwipeDragMin)
                        } else if dragPosition < AppConstants.longSwipeDragMin {
                            leftSwipeSymbol = shortLeftSymbolName
                            dragBackground = shortLeftColor
                            if prevDragPosition <= AppConstants.shortSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        } else {
                            leftSwipeSymbol = longLeftSymbolName
                            dragBackground = longLeftColor
                            if prevDragPosition <= AppConstants.longSwipeDragMin {
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
}
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable function_body_length

public extension View {
    @ViewBuilder
    // swiftlint:disable function_parameter_count
    func addSwipeyActions(isDragging: Binding<Bool>,

                          emptyLeftSymbolName: String,
                          shortLeftSymbolName: String,
                          shortLeftAction: @escaping () async -> Void,
                          shortLeftColor: Color,

                          longLeftSymbolName: String,
                          longLeftAction: @escaping () async -> Void,
                          longLeftColor: Color,

                          emptyRightSymbolName: String,
                          shortRightSymbolName: String,
                          shortRightAction: @escaping () async -> Void,
                          shortRightColor: Color,

                          longRightSymbolName: String,
                          longRightAction: @escaping () async -> Void,
                          longRightColor: Color) -> some View {
        modifier(SwipeyView(isDragging: isDragging,
                            emptyLeftSymbolName: emptyLeftSymbolName,
                            shortLeftSymbolName: shortLeftSymbolName,
                            shortLeftAction: shortLeftAction,
                            shortLeftColor: shortLeftColor,
                            longLeftSymbolName: longLeftSymbolName,
                            longLeftAction: longLeftAction,
                            longLeftColor: longLeftColor,
                            emptyRightSymbolName: emptyRightSymbolName,
                            shortRightSymbolName: shortRightSymbolName,
                            shortRightAction: shortRightAction,
                            shortRightColor: shortRightColor,
                            longRightSymbolName: longRightSymbolName,
                            longRightAction: longRightAction,
                            longRightColor: longRightColor))
    }
    // swiftlint:enable function_parameter_count
}

// TODO: ERIC - finish this implementation
// struct SwipeyActionConfig {
//    let symbolName: String
//    let emptySymbolName: String
//    let color: Color
//    let action: () async -> Void
// }
//
// struct SwipeyActionsConfig {
//    let isDragging: Binding<Bool>
//    let shortLeft: SwipeyActionConfig
//    let longLeft: SwipeyActionConfig
//    let shortRight: SwipeyActionConfig
//    let longRight: SwipeyActionConfig
// }
