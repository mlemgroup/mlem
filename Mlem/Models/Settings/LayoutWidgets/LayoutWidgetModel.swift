//
//  WidgetModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI
import Dependencies

class LayoutWidgetModel: ObservableObject {
    
    @Dependency(\.hapticManager) var hapticManager
    
    private(set) var collections: [LayoutWidgetCollection] = []
    
    @Published var widgetDragging: LayoutWidget?
    @Published var lastDraggedWidget: LayoutWidget?
    @Published var widgetDraggingCollection: LayoutWidgetCollection?
    @Published var collectionHovering: LayoutWidgetCollection?
    @Published var predictedDropCollection: LayoutWidgetCollection?
    
    @Published var widgetDraggingOffset = CGSize.zero

    init(collections: [LayoutWidgetCollection]) {
        self.collections = collections
    }
    
    var shouldShowDraggingWidget: Bool {
        widgetDraggingOffset != CGSize.zero && widgetDragging != nil
    }
    
    func setWidgetDragging(_ value: DragGesture.Value) {

        for collection in self.collections {
            if let collectionRect = collection.rect, collectionRect.contains(value.location) {
                self.collectionHovering = collection
                if widgetDraggingCollection == collection || (
                    (widgetDragging?.type.canRemove ?? true)
                    && collection.isValidDropLocation(widgetDragging)
                ) {
                    self.predictedDropCollection = collection
                }
                break
            }
        }
        
        if let widgetDragging = widgetDragging {
            // if dragging a widget, update its position
            if let rect = widgetDragging.rect {
                widgetDraggingOffset = CGSize(
                    width: rect.minX
                    + value.translation.width,
                    height: rect.minY
                    + value.translation.height
                )
            }
            
            for collection in self.collections {
                collection.update(isHovered: collection === self.predictedDropCollection, value: value, widgetDragging: widgetDragging)
            }
        } else if let collectionHovering = self.collectionHovering {
            // if not dragging a widget and hovering over a collection, pick up the widget at the drag location
            hapticManager.play(haptic: .gentleInfo, priority: .low)
            
            self.widgetDragging = collectionHovering.getItemAtLocation(value.location)
            widgetDraggingCollection = collectionHovering
            predictedDropCollection = collectionHovering
        }
    }
    
    func dropWidget() {
        hapticManager.play(haptic: .firmerInfo, priority: .low)
        
        widgetDraggingOffset = .zero
        
        if let widgetDragging = widgetDragging {
            if let index = widgetDraggingCollection!.items.firstIndex(of: widgetDragging) {
                widgetDraggingCollection!.items.remove(at: index)
            }
            predictedDropCollection!.drop(widgetDragging)
            
            lastDraggedWidget = widgetDragging
            self.widgetDragging = nil
        }
        
        predictedDropCollection = nil
    }
}
