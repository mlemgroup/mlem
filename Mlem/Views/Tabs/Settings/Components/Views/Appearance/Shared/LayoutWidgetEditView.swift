//
//  PostLayoutEditView.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

struct LayoutWidgetEditView: View {
    
    @Binding var showingSheet: Bool
    var onSave: (_ widgets: [LayoutWidgetType]) -> Void
    
    @Namespace var animation
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @StateObject var barCollection: OrderedWidgetCollection
    @StateObject var trayCollection: UnorderedWidgetCollection
    
    @StateObject private var widgetModel: LayoutWidgetModel
    
    init(_ showingSheet: Binding<Bool>, widgets: [LayoutWidgetType],
         onSave: @escaping (_ widgets: [LayoutWidgetType]) -> Void) {
        self.onSave = onSave
        
        var barWidgets: [LayoutWidget] = .init()
        
        for widget in widgets {
            barWidgets.append(.init(widget))
        }
        
        var trayWidgets: [LayoutWidget] = .init()
        
        for widget in LayoutWidgetType.allCases where !widgets.contains(widget) {
            trayWidgets.append(.init(widget))
        }
        
        let bar = OrderedWidgetCollection(barWidgets, costLimit: 7)
        _showingSheet = showingSheet
        
        let tray = UnorderedWidgetCollection(trayWidgets)
        
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
                        HStack {
                            Button("Cancel") {
                                showingSheet = false
                            }
                            Spacer()
                            Button("Save") {
                                Task {
                                    self.onSave(self.barCollection.items.compactMap { $0.type })
                                }
                                
                                showingSheet = false
                            }
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                        Divider()
                    }
                    .frame(height: 70)
                    
                    interactionBar(frame)
                        .frame(maxWidth: .infinity)
                        .frame(height: 125)
                        .padding(.horizontal, 30)
                        .zIndex(1)
                        .opacity(
                            (widgetModel.widgetDraggingCollection == trayCollection
                            && !barCollection.isValidDropLocation(widgetModel.widgetDragging))
                            ? 0.3
                            : 1
                        )
                    VStack {
                        Divider()
                        Spacer()
                        if widgetModel.widgetDraggingCollection == trayCollection
                            && !barCollection.isValidDropLocation(widgetModel.widgetDragging) {
                            Text("Too many widgets!")
                                .font(.callout)
                                .foregroundStyle(.red)
                                .padding()
                        } else {
                            Text("Tap and hold widgets to add, remove, or rearrange them.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                        Spacer()
                        Divider()
                    }
                    .frame(height: 150)
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
        
        var widgets = [LayoutWidgetType: LayoutWidget]()
        for widget in trayCollection.itemsToRender {
            widgets[widget!.type] = widget
        }
        
        func trayWidgetView(_ widgetType: LayoutWidgetType) -> some View {
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
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
            }
            trayView()
        }
    }
    
    func placedWidgetView(_ widget: LayoutWidget?, outerFrame: CGRect) -> some View {
        let widgetWidth = widget?.type.width ?? (widgetModel.widgetDragging?.type.width ?? 0)
        let stack = {
                HStack {
                GeometryReader { geometry in
                    Group {
                        if let widget = widget {
                            let widgetView = {
                                if widgetModel.widgetDragging == nil {
                                    let rect = geometry.frame(in: .global)
                                        .offsetBy(dx: -outerFrame.origin.x, dy: -outerFrame.origin.y)
                                    widget.rect = rect
                                }
                                return LayoutWidgetView(widget: widget, isDragging: false, animation: animation)
                                
                            }
                            
                            widgetView()
                        } else {
                            Color.clear
                                .frame(maxWidth: widgetWidth, maxHeight: .infinity)
                                .padding(10)
                        }
                    }
                }
            }
            .transition(.scale(scale: 1))
            .zIndex(widgetModel.lastDraggedWidget == widget ? 1 : 0)
        }
        
        return HStack {
            if widgetWidth == .infinity {
                stack().frame(maxWidth: .infinity)
            } else {
                stack().frame(width: widgetWidth)
            }
        }
        .transition(.scale(scale: 1))
    }
}
