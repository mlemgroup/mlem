//
//  PostLayoutEditView.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

struct PostLayoutEditView: View {
    
    @Namespace var animation
    @StateObject var barCollection: OrderedLayoutWidgetCollection
    @StateObject var trayCollection: UnorderedWidgetCollection
    
    @StateObject private var widgetModel: LayoutWidgetModel
    
    init() {
        let bar = OrderedLayoutWidgetCollection([
            .init(.upvote),
            .init(.downvote),
            .init(.spacer),
            .init(.save)
       ])
        let tray = UnorderedWidgetCollection([.init(.reply)])
        
        _barCollection = StateObject(wrappedValue: bar)
        _trayCollection = StateObject(wrappedValue: tray)
        _widgetModel = StateObject(wrappedValue: LayoutWidgetModel(collections: [bar, tray]))
    }
    
    func interactionBarWidgetView(_ widget: PostLayoutWidget, outerFrame: CGRect) -> some View {
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
                                .offsetBy(dx: -outerFrame.origin.x - 10, dy: -outerFrame.origin.y - 70)
                            widget.rect = rect
                        }
                        return LayoutWidgetView(widget: widget, isDragging: false, animation: animation)

                    }
                    
                    widgetView()
                }
            }
        }
        .frame(maxWidth: widget.type.width)
    }
    
    func interactionBar(_ outerFrame: CGRect) -> some View {
        GeometryReader { geometry in
            let interactionbarView = {
                let rect = geometry.frame(in: .global).offsetBy(dx: 0, dy: -outerFrame.origin.y - 70)
                barCollection.rect = rect
                
                return HStack(spacing: 10) {
                    ForEach(barCollection.itemsToRender, id: \.self) { widget in
                        interactionBarWidgetView(widget, outerFrame: outerFrame)
                            .transition(.scale(scale: 1))
                            .zIndex(widgetModel.lastDraggedWidget == widget ? 1 : 0)
                    }
                }
                .animation(.default, value: barCollection.itemsToRender)
                .zIndex(1)
                .transition(.scale(scale: 1))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .padding(.vertical, 80)
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
                
            }
            interactionbarView()
        }
    }
    
    func tray(_ outerFrame: CGRect) -> some View {
        GeometryReader { geometry in
            let trayView = {
                let rect = geometry
                    .frame(in: .global).offsetBy(dx: 0, dy: -outerFrame.origin.y - 90)
                trayCollection.rect = rect
                
                return VStack {
                    if widgetModel.predictedDropCollection === trayCollection {
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
                        VStack {
                            HStack {
                                Text("Tray")
                            }
                            .padding(10)
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
            }
            trayView()
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .global)
                VStack(spacing: 0) {
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
                        .frame(height: 200)
                        .padding(.horizontal, 10)
                    Divider()
                    Text("Tap and hold widgets to add, remove, or rearrange them.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                    Divider()
                    Spacer()
                    tray(frame)
                    Spacer()
                }
            }
            
            if widgetModel.shouldShowDraggingWidget {
                HStack {
                    LayoutWidgetView(widget: widgetModel.widgetDragging!, animation: animation)
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
        .background(Color(UIColor.systemGroupedBackground))
    }
    
}
