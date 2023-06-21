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
            
            // content
            content
                .offset(x: dragPosition)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
                        .updating($dragState) { value, state, transaction in
                            // this check adds a dead zone to the left side of the screen so it doesn't interfere with navigation
                            if dragState != .zero || value.location.x > 50 {
                                state = value.translation.width
                            }
                        }
                )
                .onChange(of: dragState) { newDragState in
                    if newDragState == .zero {
                        let w = prevDragPosition
                        // TODO: instant upvote feedback (waiting on backend)
                        if w < -1 * AppConstants.longSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await longRightAction()
                            }
                        }
                        else if w < -1 * AppConstants.shortSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await shortRightAction()
                            }
                        }
                        else if w > AppConstants.longSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await longLeftAction()
                            }
                        }
                        else if w > AppConstants.shortSwipeDragMin {
                            Task(priority: .userInitiated) {
                                await shortLeftAction()
                            }
                        }
                        withAnimation(.interactiveSpring()) {
                            dragPosition = .zero
                            leftSwipeSymbol = emptyLeftSymbolName
                            rightSwipeSymbol = emptyRightSymbolName
                            dragBackground = .systemBackground
                        }
                    }
                    else {
                        dragPosition = newDragState
                        let w = newDragState
                        
                        if w < -1 * AppConstants.longSwipeDragMin {
                            rightSwipeSymbol = longRightSymbolName
                            dragBackground = longRightColor
                            if prevDragPosition >= -1 * AppConstants.longSwipeDragMin {
                                // AppConstants.hapticManager.notificationOccurred(.success)
                                tapper.impactOccurred()
                            }
                        }
                        else if w < -1 * AppConstants.shortSwipeDragMin {
                            rightSwipeSymbol = shortRightSymbolName
                            dragBackground = shortRightColor
                            if prevDragPosition >= -1 * AppConstants.shortSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        }
                        else if w < 0 {
                            rightSwipeSymbol = emptyRightSymbolName
                            dragBackground = shortRightColor.opacity(-1 * w / AppConstants.shortSwipeDragMin)
                        }
                        else if w < AppConstants.shortSwipeDragMin {
                            leftSwipeSymbol = emptyLeftSymbolName
                            dragBackground = shortLeftColor.opacity(w / AppConstants.shortSwipeDragMin)
                        }
                        else if w < AppConstants.longSwipeDragMin {
                            leftSwipeSymbol = shortLeftSymbolName
                            dragBackground = shortLeftColor
                            if prevDragPosition <= AppConstants.shortSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        }
                        else {
                            leftSwipeSymbol = longLeftSymbolName
                            dragBackground = longLeftColor
                            if prevDragPosition <= AppConstants.longSwipeDragMin {
                                tapper.impactOccurred()
                            }
                        }
                        prevDragPosition = w
                    }
                }
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .buttonStyle(EmptyButtonStyle()) // disables links from highlighting when tapped
    }
    
    // helpers
    // func reset
}

public extension View {
    @ViewBuilder
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
}

