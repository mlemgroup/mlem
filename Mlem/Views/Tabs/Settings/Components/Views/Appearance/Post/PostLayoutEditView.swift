//
//  PostLayoutEditView.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

private struct WidgetView: View {
    
    var widget: PostLayoutWidget
    var isDragging: Bool = false
    
    var animation: Namespace.ID
    
    func icon(_ imageName: String) -> some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
    }
    
    var body: some View {
        HStack {
            switch widget.type {
            case .upvote:
                icon("arrow.up")
            case .downvote:
                icon("arrow.down")
            case .save:
                icon("bookmark")
            case .reply:
                icon("arrowshape.turn.up.left")
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        // .shadow(color: .black.opacity(0.05), radius: 3, x: 3, y: 3)
        .matchedGeometryEffect(id: "Widget\(widget.hashValue)", in: animation)
        .transition(.scale(scale: 1))
    }
}

struct PostLayoutEditView: View {
    
    @Namespace var animation
    @StateObject private var widgetModel: LayoutWidgetModel = .init()
    
    func interactionBarwidgetView(_ widget: PostLayoutWidget, outerFrame: CGRect) -> some View {
        HStack {
            GeometryReader { geometry in
                
                switch widget.type {
                case .placeholder(let wrappedValue):
                    Color.clear
                        .frame(maxWidth: wrappedValue.width, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(10)
                default:
                    let widgetView = {
                        if widgetModel.widgetDragging == nil {
                            let rect = geometry.frame(in: .global)
                                .offsetBy(dx: -outerFrame.origin.x - 10, dy: -outerFrame.origin.y - 100)
                            widgetModel.setItemRect(widget, rect)
                        }
                        return WidgetView(widget: widget, isDragging: false, animation: animation)

                    }
                    
                    widgetView()
                }
            }
        }
        .frame(maxWidth: widget.type.width)
    }
    
    func interactionBar(_ outerFrame: CGRect) -> some View {
        HStack(spacing: 10) {
            ForEach(widgetModel.itemsWithPlaceholder, id: \.self) { widget in
                interactionBarwidgetView(widget, outerFrame: outerFrame)
                    .transition(.scale(scale: 1))
                    .zIndex(widgetModel.lastDraggedWidget == widget ? 1 : 0)
            }
        }
        .zIndex(1)
        .transition(.scale(scale: 1))
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    widgetModel.setWidgetDragging(value)
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        widgetModel.dropWidget()
                    }
                }
        )
        .padding(10)
    }
    
    func tray(_ outerFrame: CGRect) -> some View {
        GeometryReader { geometry in
            let callback = {
                widgetModel.trayY = geometry
                    .frame(in: .global)
                    .minY - outerFrame.origin.y - 90
            }
            VStack {
                if widgetModel.predictedDropLocation == .tray {
                    VStack {
                        Image(systemName: "trash")
                            .resizable()
                            .foregroundStyle(.red)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .padding(100)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(20)
                } else {
                    Text("Tray")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .onAppear(perform: callback)
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .global)
                VStack(spacing: 20) {
                    VStack {
                        Spacer()
                        Text("Customise Widgets")
                            .fontWeight(.semibold)
                            .font(.title2)
                        Spacer()
                        Divider()
                    }
                    .frame(height: 70)
                    interactionBar(frame)
                        .frame(maxWidth: .infinity)
                    Divider()
                    Text("Tap and hold widgets to add, remove, or rearrange them.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Divider()
                    Spacer()
                    tray(frame)
                    Spacer()
                }
            }
            
            if widgetModel.shouldShowDraggingWidget {
                HStack {
                    WidgetView(widget: widgetModel.widgetDragging!, animation: animation)
                }
                .frame(
                    width: widgetModel.widgetDragging!.rect!.width,
                    height: widgetModel.widgetDragging!.rect!.height
                )
                .offset(widgetModel.widgetDraggingOffset)
                .zIndex(2)
                .transition(.scale(scale: 1))
            }
        }
        .animation(.default, value: widgetModel.itemsWithPlaceholder)
        // .animation(.easeOut(duration: 0.2), value: widgetModel.widgetDragging)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
}
