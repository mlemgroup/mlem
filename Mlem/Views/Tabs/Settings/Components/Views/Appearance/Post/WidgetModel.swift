//
//  WidgetModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

class LayoutWidgetModel: ObservableObject {
    
    private(set) var collections: [LayoutWidgetCollection] = []
    
    @Published var trayY: CGFloat = 0
    
    @Published var widgetDragging: PostLayoutWidget?
    @Published var lastDraggedWidget: PostLayoutWidget?
    @Published var widgetDraggingCollection: LayoutWidgetCollection?
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
                self.predictedDropCollection = collection
                break
            }
        }
        if widgetDragging == nil && self.predictedDropCollection != nil {
            self.widgetDragging = self.predictedDropCollection!.getItemAtLocation(value.location)
            widgetDraggingCollection = predictedDropCollection
        }
        
        if widgetDragging != nil {
            
            widgetDraggingOffset = CGSize(
                width: widgetDragging!.rect!.origin.x
                + value.translation.width + 10,
                height: widgetDragging!.rect!.origin.y
                + value.translation.height + 70
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
