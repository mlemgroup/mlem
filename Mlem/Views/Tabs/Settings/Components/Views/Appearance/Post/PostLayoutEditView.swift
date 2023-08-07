//
//  PostLayoutEditView.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

struct PostLayoutEditView: View {
    
    @Binding var showingSheet: Bool
    
    @Namespace var animation
    @StateObject var barCollection: OrderedWidgetCollection
    @StateObject var trayCollection: UnorderedWidgetCollection
    
    @StateObject private var widgetModel: LayoutWidgetModel
    
    init(_ showingSheet: Binding<Bool>) {
        let bar = OrderedWidgetCollection([
            .init(.upvote),
            .init(.downvote),
            .init(.spacer),
            .init(.save)
       ])
        _showingSheet = showingSheet
        let tray = UnorderedWidgetCollection([
            .init(.scoreCounter),
            .init(.upvoteCounter),
            .init(.downvoteCounter),
            .init(.reply),
            .init(.share)
        ])
        
        _barCollection = StateObject(wrappedValue: bar)
        _trayCollection = StateObject(wrappedValue: tray)
        _widgetModel = StateObject(wrappedValue: LayoutWidgetModel(collections: [bar, tray]))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .global)
                VStack(spacing: 0) {
                    VStack {
                        Spacer()
                        ZStack {
                            Text("Customise Widgets")
                                .fontWeight(.semibold)
                                .font(.title2)
                            HStack {
                                Spacer()
                                Button {
                                    showingSheet = false
                                } label: {
                                    Image(systemName: "multiply.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 26)
                                        .foregroundStyle(.tertiary)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                        }
                        Spacer()
                        Divider()
                    }
                    .frame(height: 70)
                    
                    interactionBar(frame)
                        .frame(maxWidth: .infinity)
                        .frame(height: 125)
                        .padding(.horizontal, 30)
                        .zIndex(1)
                    VStack {
                        Divider()
                        Text("Tap and hold widgets to add, remove, or rearrange them.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding()
                        Divider()
                    }
                    tray(frame)
                        .padding(.vertical, 40)
                        .zIndex(1)
                    Spacer()
                }
            }
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
        
            if widgetModel.shouldShowDraggingWidget {
                HStack {
                    PostLayoutWidgetView(widget: widgetModel.widgetDragging!, animation: animation)
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
    
    func interactionBar(_ outerFrame: CGRect) -> some View {
        Group {
            GeometryReader { geometry in
                let interactionbarView = {
                    let rect = geometry.frame(in: .global).offsetBy(dx: 0, dy: -outerFrame.origin.y)
                    barCollection.rect = rect.insetBy(dx: -20, dy: -60)
                    
                    return HStack(spacing: 10) {
                        ForEach(barCollection.itemsToRender, id: \.self) { widget in
                            placedWidgetView(widget, outerFrame: outerFrame)
                        }
                    }
                    .animation(.default, value: barCollection.itemsToRender)
                    .zIndex(1)
                    .transition(.scale(scale: 1))
                }
                interactionbarView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
    }
    
    func tray(_ outerFrame: CGRect) -> some View {
        
        var widgets = [PostLayoutWidgetType: PostLayoutWidget]()
        for widget in trayCollection.itemsToRender {
            widgets[widget.type] = widget
        }
        
        func trayWidgetView(_ widgetType: PostLayoutWidgetType) -> some View {
            Group {
                if let widget = widgets[widgetType] {
                    placedWidgetView(widget, outerFrame: outerFrame)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(UIColor.secondarySystemGroupedBackground), lineWidth: 1.5)
                }
            }
            .frame(width: widgetType.width == .infinity ? 150 : widgetType.width, height: 40)
        }
        
        return GeometryReader { geometry in
            
            let trayView = {
                let rect = geometry
                    .frame(in: .global).offsetBy(dx: 0, dy: -outerFrame.origin.y - 90)
                trayCollection.rect = rect
                
                return VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        trayWidgetView(.scoreCounter)
                        trayWidgetView(.upvoteCounter)
                        trayWidgetView(.downvoteCounter)
                    }
                    HStack(spacing: 20) {
                        trayWidgetView(.upvote)
                        trayWidgetView(.downvote)
                        trayWidgetView(.save)
                        trayWidgetView(.share)
                        trayWidgetView(.reply)
                    }
                    HStack(spacing: 20) {
                        trayWidgetView(.spacer)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
            }
            trayView()
        }
    }
    
    func placedWidgetView(_ widget: PostLayoutWidget, outerFrame: CGRect) -> some View {
        HStack {
            GeometryReader { geometry in
                
                switch widget.type {
                case .placeholder(let wrappedValue):
                    Color.clear
                        .frame(maxWidth: wrappedValue.width, maxHeight: .infinity)
                        .padding(10)
                default:
                    let widgetView = {
                        if widgetModel.widgetDragging == nil {
                            let rect = geometry.frame(in: .global)
                                .offsetBy(dx: -outerFrame.origin.x, dy: -outerFrame.origin.y)
                            widget.rect = rect
                        }
                        return PostLayoutWidgetView(widget: widget, isDragging: false, animation: animation)

                    }
                    
                    widgetView()
                }
            }
        }
        .frame(maxWidth: widget.type.width)
        .transition(.scale(scale: 1))
        .zIndex(widgetModel.lastDraggedWidget == widget ? 1 : 0)
    }
}
