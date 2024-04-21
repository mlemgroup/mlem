//
//  LayoutWidgetEditView.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import Dependencies
import SwiftUI

enum LayoutWidgetMode {
    case user, moderator
}

struct LayoutWidgetEditView: View {
    @Environment(\.isPresented) var isPresented
    
    let mode: LayoutWidgetMode
    var onSave: (_ widgets: [LayoutWidgetType]) -> Void
    
    @Namespace var animation
    
    @StateObject var barCollection: OrderedWidgetCollection
    @StateObject var trayCollection: InfiniteWidgetCollection
    
    @StateObject private var widgetModel: LayoutWidgetModel
    
    var defaultLayout: [LayoutWidgetType] {
        switch mode {
        case .user:
            [.scoreCounter, .infoStack, .save, .reply]
        case .moderator:
            [.resolve, .remove, .infoStack, .ban, .purge]
        }
    }
    
    init(
        mode: LayoutWidgetMode,
        widgets: [LayoutWidgetType],
        onSave: @escaping (_ widgets: [LayoutWidgetType]) -> Void
    ) {
        self.onSave = onSave
        
        let barWidgets = widgets.map { LayoutWidget($0) }
        
        let bar = OrderedWidgetCollection(barWidgets, costLimit: 7)
        
        let trayWidgets: [LayoutWidgetType] = switch mode {
        case .moderator:
            [.resolve, .remove, .ban, .purge]
        case .user:
            [
                .upvote,
                .downvote,
                .save,
                .reply,
                .share,
                .upvoteCounter,
                .downvoteCounter,
                .scoreCounter
            ]
        }
        
        let tray = InfiniteWidgetCollection(
            trayWidgets.map { LayoutWidget($0) }
        )
        
        _barCollection = StateObject(wrappedValue: bar)
        _trayCollection = StateObject(wrappedValue: tray)
        _widgetModel = StateObject(wrappedValue: LayoutWidgetModel(collections: [bar, tray]))
        self.mode = mode
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .global)
                VStack(spacing: 0) {
                    interactionBar(frame)
                        .frame(height: 125)
                        .padding(.horizontal, 30)
                        .zIndex(1)
                        .opacity(
                            (widgetModel.widgetDraggingCollection == trayCollection
                                && !barCollection.isValidDropLocation(widgetModel.widgetDragging))
                                ? 0.3
                                : 1
                        )
                    infoText
                    tray(frame)
                        .padding(.vertical, 40)
                        .zIndex(1)
                    Spacer()
                    Button("Reset") {
                        barCollection.replaceItems(with: defaultLayout)
                        Task {
                            onSave(barCollection.items.map(\.type))
                        }
                    }
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
                }
                .fancyTabScrollCompatible()
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
        
            if widgetModel.shouldShowDraggingWidget, let widgetDragging = widgetModel.widgetDragging, let rect = widgetDragging.rect {
                HStack {
                    LayoutWidgetView(widget: widgetDragging, animation: animation)
                }
                .frame(
                    width: rect.width,
                    height: rect.height
                )
                .offset(widgetModel.widgetDraggingOffset)
                .zIndex(2)
                .transition(.scale(scale: 1))
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onChange(of: isPresented) { newValue in
            if newValue == false {
                Task {
                    onSave(barCollection.items.map(\.type))
                }
            }
        }
        .navigationTitle("Widgets")
        .navigationBarColor()
        .hoistNavigation()
    }
    
    var infoText: some View {
        VStack {
            Divider()
            Spacer()
            if widgetModel.widgetDraggingCollection == trayCollection,
               !barCollection.isValidDropLocation(widgetModel.widgetDragging) {
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
    }
    
    func interactionBar(_ outerFrame: CGRect) -> some View {
        HStack(spacing: 10) {
            ForEach(barCollection.itemsToRender, id: \.self) { widget in
                if let widget {
                    placedWidgetView(widget, outerFrame: outerFrame)
                } else {
                    Color.clear
                        .frame(maxWidth: widgetModel.widgetDragging?.type.width ?? 0, maxHeight: .infinity)
                }
            }
        }
        .animation(.default, value: barCollection.itemsToRender)
        .zIndex(1)
        .transition(.scale(scale: 1))
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .overlay {
            // little hack to determine the frame after rendering and update the collection
            GeometryReader { geo in
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        barCollection.rect = geo.frame(in: .global)
                            .offsetBy(dx: -outerFrame.origin.x, dy: -outerFrame.origin.y)
                            .insetBy(dx: -20, dy: -60)
                    }
            }
        }
    }
    
    func tray(_ outerFrame: CGRect) -> some View {
        let widgets = trayCollection.getItemDictionary()
        return VStack(spacing: 20) {
            switch mode {
            case .user:
                HStack(spacing: 20) {
                    trayWidgetView(.scoreCounter, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.upvoteCounter, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.downvoteCounter, widgets: widgets, outerFrame: outerFrame)
                }
                HStack(spacing: 20) {
                    trayWidgetView(.upvote, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.downvote, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.save, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.share, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.reply, widgets: widgets, outerFrame: outerFrame)
                }
            case .moderator:
                HStack(spacing: 20) {
                    trayWidgetView(.resolve, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.remove, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.ban, widgets: widgets, outerFrame: outerFrame)
                    trayWidgetView(.purge, widgets: widgets, outerFrame: outerFrame)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .overlay {
            // little hack to determine the frame after rendering and update the collection
            GeometryReader { geo in
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        var rect = geo.frame(in: .global)
                            .offsetBy(dx: -outerFrame.origin.x, dy: -outerFrame.origin.y)
                        // Extend the rect into the infoText area a little
                        rect.origin.y -= 130
                        rect.size.height += 130
                        trayCollection.rect = rect
                    }
            }
        }
    }
    
    func trayWidgetView(_ widgetType: LayoutWidgetType, widgets: [LayoutWidgetType: LayoutWidget], outerFrame: CGRect) -> some View {
        Group {
            if let widget = widgets[widgetType] {
                placedWidgetView(widget, outerFrame: outerFrame)
            }
        }
        .frame(width: widgetType.width == .infinity ? 150 : widgetType.width, height: 40)
        .zIndex(widgetModel.lastDraggedWidget?.type == widgetType ? 1 : 0)
    }
    
    func placedWidgetView(_ widget: LayoutWidget, outerFrame: CGRect) -> some View {
        let widgetWidth = widget.type.width

        return HStack {
            GeometryReader { geometry in
                Group {
                    placedWidgetViewWrapper(widget, outerFrame: outerFrame, geometry: geometry)
                }
            }
        }
        .zIndex(widgetModel.lastDraggedWidget == widget ? 1 : 0)
        .frame(maxWidth: .infinity)
        .frame(width: widgetWidth == .infinity ? nil : widgetWidth)
        .transition(.scale(scale: 1))
    }
    
    func placedWidgetViewWrapper(_ widget: LayoutWidget, outerFrame: CGRect, geometry: GeometryProxy) -> some View {
        if widgetModel.widgetDragging == nil {
            let rect = geometry.frame(in: .global)
                .offsetBy(dx: -outerFrame.origin.x, dy: -outerFrame.origin.y)
            widget.rect = rect
        }
        return LayoutWidgetView(widget: widget, isDragging: false, animation: animation)
    }
}
