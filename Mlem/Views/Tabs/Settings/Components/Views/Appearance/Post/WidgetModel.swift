//
//  WidgetModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

class LayoutWidgetModel: ObservableObject {
    
    private(set) var collections: [LayoutWidgetCollection] = []
    
    @Published var widgetDragging: PostLayoutWidget?
    @Published var lastDraggedWidget: PostLayoutWidget?
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

        for collection in self.collections where collection.rect != nil {
            if collection.rect!.contains(value.location) {
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
        if widgetDragging == nil && self.collectionHovering != nil {
            self.widgetDragging = self.collectionHovering!.getItemAtLocation(value.location)
            widgetDraggingCollection = collectionHovering
            predictedDropCollection = collectionHovering
        }
        
        if widgetDragging != nil {
            widgetDraggingOffset = CGSize(
                width: widgetDragging!.rect!.minX
                + value.translation.width,
                height: widgetDragging!.rect!.minY
                + value.translation.height
            )
            
            for collection in self.collections {
                collection.update(isHovered: collection === self.predictedDropCollection, value: value, widgetDragging: widgetDragging!)
            }
        }
    }
    
    func dropWidget() {
        widgetDraggingOffset = .zero
        
        if widgetDragging != nil {
            if let index = widgetDraggingCollection!.items.firstIndex(of: widgetDragging!) {
                widgetDraggingCollection!.items.remove(at: index)
            }
            predictedDropCollection!.drop(widgetDragging!)
            
            lastDraggedWidget = widgetDragging
            widgetDragging = nil
        }
        
        predictedDropCollection = nil
    }
}
