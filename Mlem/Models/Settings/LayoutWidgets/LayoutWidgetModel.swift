//
//  LayoutWidgetModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import Dependencies
import SwiftUI

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
        for collection in collections {
            if let collectionRect = collection.rect, collectionRect.contains(value.location) {
                collectionHovering = collection
                if widgetDraggingCollection == collection || (
                    (widgetDragging?.type.canRemove ?? true)
                        && collection.isValidDropLocation(widgetDragging)
                ) {
                    predictedDropCollection = collection
                }
                break
            }
        }
        
        if let widgetDragging {
            // if dragging a widget, update its position
            if let rect = widgetDragging.rect {
                widgetDraggingOffset = CGSize(
                    width: rect.minX
                        + value.translation.width,
                    height: rect.minY
                        + value.translation.height
                )
            }
            
            for collection in collections {
                collection.update(isHovered: collection === predictedDropCollection, value: value, widgetDragging: widgetDragging)
            }
        } else if let collectionHovering {
            // if not dragging a widget and hovering over a collection, pick up the widget at the drag location
            widgetDragging = collectionHovering.getItemAtLocation(value.location)
            if widgetDragging != nil { hapticManager.play(haptic: .gentleInfo, priority: .low) }
            widgetDraggingCollection = collectionHovering
            predictedDropCollection = collectionHovering
        }
    }
    
    func dropWidget() {
        hapticManager.play(haptic: .lightSuccess, priority: .low)
        
        widgetDraggingOffset = .zero
        
        if let widgetDragging {
            if let collection = widgetDraggingCollection {
                collection.removeFrom(widgetDragging)
            }
            if let collection = predictedDropCollection {
                collection.addTo(widgetDragging)
            }
            
            lastDraggedWidget = widgetDragging
            self.widgetDragging = nil
        }
        
        predictedDropCollection = nil
    }
}
