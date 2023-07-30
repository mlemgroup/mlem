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
    
    var body: some View {
        VStack {
            Text(widget.type.rawValue)
        }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .matchedGeometryEffect(id: "Widget\(widget.hashValue)\(isDragging)", in: animation)
    }
}

struct PostLayoutEditView: View {
    
    @Namespace var animation
    
    @StateObject private var widgetModel: LayoutWidgetModel = .init()
    
    @State private var widgetDragging: PostLayoutWidget?
    @State private var offset = CGSize.zero
    
    @State private var hoveringTray: Bool = false
    
    func interactionBarwidgetView(_ widget: PostLayoutWidget, outerFrame: CGRect) -> some View {
        GeometryReader { geometry in
            
            let callback = {
                let rect = geometry.frame(in: .global)
                    .offsetBy(dx: -outerFrame.origin.x, dy: -outerFrame.origin.y - 250)
                widgetModel.setItemRect(widget, rect)
            }
            
            WidgetView(widget: widget, isDragging: false, animation: animation)
                .padding(10)
                .onAppear(perform: callback)
                .onChange(of: geometry.size) { _ in callback() }
        }
    }
    
    func interactionBar(_ outerFrame: CGRect) -> some View {
        HStack(spacing: 0) {
            ForEach(widgetModel.items, id: \.self) { widget in
                interactionBarwidgetView(widget, outerFrame: outerFrame)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if widgetDragging == nil {
                        widgetDragging = widgetModel.getItemAtLocation(value.location)
                        if widgetDragging != nil {
                            widgetModel.removeItem(widgetDragging!)
                        }
                    }
                    
                    if widgetDragging != nil {
                        offset = CGSize(
                            width: widgetDragging!.rect!.origin.x
                            + value.translation.width,
                            height: widgetDragging!.rect!.origin.y
                            + value.translation.height + 250
                        )
                    }
                }
                .onEnded { _ in
                    offset = .zero
                    hoveringTray = false
                    if widgetDragging != nil {
                        widgetModel.addItem(widgetDragging!, index: 0)
                    }
                    widgetDragging = nil
                }
        )
    }
    
    func tray() -> some View {
        VStack {
            if hoveringTray {
                Image(systemName: "trash")
                    .resizable()
                    .foregroundStyle(.red)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                    .padding(100)
                Spacer()
            } else {
                Text("Tray")
            }
        }
        .frame(height: 600)
        .frame(maxWidth: .infinity)
        .background(hoveringTray ? .red.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 20) {
                    GeometryReader { geometry in
                        let frame = geometry.frame(in: .global)
                        VStack {
                            Text(widgetDragging?.type.rawValue ?? "None")
                            Spacer()
                            interactionBar(frame)
                        }
                    }
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    tray()
                }
                
                if offset != CGSize.zero && widgetDragging != nil {
                    HStack {
                        WidgetView(widget: widgetDragging!, animation: animation)
                            .padding(10)
                    }
                    .frame(width: widgetDragging!.rect!.width, height: widgetDragging!.rect!.height)
                    .offset(offset)
                    .zIndex(1)
                }
            }
            .padding(20)
            .animation(.easeOut(duration: 0.2), value: widgetDragging)
        }
        .fancyTabScrollCompatible()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
}
