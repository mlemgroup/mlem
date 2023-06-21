//
//  Swipey Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct SwipeyView: ViewModifier {
    // state
    @State var dragPosition: CGSize = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color = .systemBackground
    @State var leftSwipeSymbol: String
    @State var rightSwipeSymbol: String
    
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
    init(emptyLeftSymbolName: String,
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
                .offset(x: dragPosition.width)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 15) // min distance prevents conflict with scrolling drag gesture
                        .onChanged {
                            let w = $0.translation.width
                            
                            if w < -1 * AppConstants.longSwipeDragMin {
                                rightSwipeSymbol = longRightSymbolName
                                dragBackground = longRightColor
                                if prevDragPosition >= -1 * AppConstants.longSwipeDragMin {
                                    AppConstants.hapticManager.notificationOccurred(.success)
                                }
                            }
                            else if w < -1 * AppConstants.shortSwipeDragMin {
                                rightSwipeSymbol = shortRightSymbolName
                                dragBackground = shortRightColor
                                if prevDragPosition >= -1 * AppConstants.shortSwipeDragMin {
                                    AppConstants.hapticManager.notificationOccurred(.success)
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
                                    AppConstants.hapticManager.notificationOccurred(.success)
                                }
                            }
                            else {
                                leftSwipeSymbol = longLeftSymbolName
                                dragBackground = longLeftColor
                                if prevDragPosition <= AppConstants.longSwipeDragMin {
                                    AppConstants.hapticManager.notificationOccurred(.success)
                                }
                            }
                            prevDragPosition = w
                            dragPosition = $0.translation
                        }
                        .onEnded {
                            let w = $0.translation.width
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
                )
        } 
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .buttonStyle(EmptyButtonStyle()) // disables links from highlighting when tapped
    }
}

public extension View {
    @ViewBuilder
    func addSwipeyActions(emptyLeftSymbolName: String,
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
        modifier(SwipeyView(emptyLeftSymbolName: emptyLeftSymbolName,
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
