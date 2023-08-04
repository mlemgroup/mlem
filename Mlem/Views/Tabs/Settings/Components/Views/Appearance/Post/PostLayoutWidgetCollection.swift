//
//  PostLayoutWidgetCollection.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

class LayoutWidgetCollection: ObservableObject {
    @Published var items: [PostLayoutWidget] = .init()
    var itemsToRender: [PostLayoutWidget] { self.items }
    var rect: CGRect?
    
    init(_ items: [PostLayoutWidget]) {
        _items = Published(wrappedValue: items)
    }
    
    func update(isHovered: Bool, value: DragGesture.Value, widgetDragging: PostLayoutWidget) {}
    
    func drop(_ widget: PostLayoutWidget) {
        self.items.append(widget)
    }
    
    func getItemAtLocation(_ location: CGPoint) -> PostLayoutWidget? {
        for widget in items where widget.rect != nil {
            if widget.rect?.contains(location) ?? false {
                return widget
            }
        }
        return nil
    }
}

class UnorderedWidgetCollection: LayoutWidgetCollection {
    
}

class OrderedLayoutWidgetCollection: LayoutWidgetCollection {
    
    @Published var itemsWithPlaceholder: [PostLayoutWidget] = .init()
    override var itemsToRender: [PostLayoutWidget] { self.itemsWithPlaceholder }
    var predictedDropIndex: Int?
    
    override init(_ items: [PostLayoutWidget]) {
        super.init(items)
        itemsWithPlaceholder = self.items
    }
    
    override func update(isHovered: Bool, value: DragGesture.Value, widgetDragging: PostLayoutWidget) {
        if isHovered {
            if value.translation.width == 0 {
                self.predictedDropIndex = self.items.firstIndex(of: widgetDragging)!
            } else {
                self.setPredictedDropIndex(value: value, widgetDragging: widgetDragging)
            }
            updatePlaceholderPosition(widgetDragging: widgetDragging, index: predictedDropIndex!)
        } else {
            removePlaceholder(widgetDragging: widgetDragging)
        }
    }
    
    override func drop(_ widget: PostLayoutWidget) {
        self.items.insert(widget, at: predictedDropIndex!)
        itemsWithPlaceholder = items
    }
    
    func updatePlaceholderPosition(widgetDragging: PostLayoutWidget, index: Int) {
        var retItems = self.items
        retItems.remove(at: retItems.firstIndex(of: widgetDragging)!)
        self.itemsWithPlaceholder = Array(
            retItems[ 0 ..< index]
            + [PostLayoutWidget(.placeholder(wrappedValue: widgetDragging.type))]
            + retItems[ index ..< retItems.count]
        )
    }
    func removePlaceholder(widgetDragging: PostLayoutWidget) {
        var retItems = self.items
        retItems.remove(at: retItems.firstIndex(of: widgetDragging)!)
        self.itemsWithPlaceholder = retItems
    }
    
    func setPredictedDropIndex(value: DragGesture.Value, widgetDragging: PostLayoutWidget) {
        var nodes: [Float] = []
        
        for item in self.items {
            if value.translation.width < 0 {
                nodes.append(Float(item.rect!.minX) + 5)
            } else {
                nodes.append(Float(item.rect!.maxX) + 15)
            }
        }
        let comparisonX = Float(widgetDragging.rect!.origin.x + value.translation.width + 10)
                        + Float(widgetDragging.rect!.width) / 2.0

        let closest = nodes.enumerated().min(by: {
            abs($0.element - comparisonX) < abs($1.element - comparisonX)
        })
        self.predictedDropIndex = closest!.offset
    }
}
