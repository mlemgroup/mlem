//
//  LayoutWidgetCollection.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

class LayoutWidgetCollection: ObservableObject, Equatable {
    
    var id = UUID()
    @Published var items: [LayoutWidget] = .init()
    var itemsToRender: [LayoutWidget?] { self.items }
    var rect: CGRect?
    var costLimit: Float
    
    init(_ items: [LayoutWidget], costLimit: Float = .infinity) {
        _items = Published(wrappedValue: items)
        self.costLimit = costLimit
    }
    
    func update(isHovered: Bool, value: DragGesture.Value, widgetDragging: LayoutWidget) {}
    
    func drop(_ widget: LayoutWidget) {
        self.items.append(widget)
    }
    
    func getItemAtLocation(_ location: CGPoint) -> LayoutWidget? {
        for widget in items where widget.rect != nil {
            if widget.rect?.contains(location) ?? false {
                return widget
            }
        }
        return nil
    }
    
    func isValidDropLocation(_ widgetDragging: LayoutWidget? = nil) -> Bool {
        costLimit == .infinity || totalCost(widgetDragging) <= costLimit
    }
    
    func totalCost(_ widgetDragging: LayoutWidget? = nil) -> Float {
        self.items.reduce(0) { accumulator, element in
            accumulator + element.type.cost
        } + (widgetDragging?.type.cost ?? 0)
    }
    
    static func == (lhs: LayoutWidgetCollection, rhs: LayoutWidgetCollection) -> Bool {
        lhs.id == rhs.id
    }
    
}

class UnorderedWidgetCollection: LayoutWidgetCollection {
    
}

class OrderedWidgetCollection: LayoutWidgetCollection {
    
    @Published var itemsWithPlaceholder: [LayoutWidget?] = .init()
    override var itemsToRender: [LayoutWidget?] { self.itemsWithPlaceholder }
    var predictedDropIndex: Int?
    
    override init(_ items: [LayoutWidget], costLimit: Float = .infinity) {
        super.init(items, costLimit: costLimit)
        itemsWithPlaceholder = self.items
    }
    
    override func update(isHovered: Bool, value: DragGesture.Value, widgetDragging: LayoutWidget) {
        if isHovered {
            if value.translation.width == 0 && self.items.contains(widgetDragging) {
                self.predictedDropIndex = self.items.firstIndex(of: widgetDragging)
            } else {
                self.setPredictedDropIndex(value: value, widgetDragging: widgetDragging)
            }
            updatePlaceholderPosition(widgetDragging: widgetDragging, index: predictedDropIndex!)
        } else {
            removePlaceholder(widgetDragging: widgetDragging)
        }
    }
    
    override func drop(_ widget: LayoutWidget) {
        self.items.insert(widget, at: predictedDropIndex!)
        itemsWithPlaceholder = items
    }
    
    func updatePlaceholderPosition(widgetDragging: LayoutWidget, index: Int) {
        var retItems = self.items
        if let widgetDraggingIndex = retItems.firstIndex(of: widgetDragging) {
            retItems.remove(at: widgetDraggingIndex)
        }
        self.itemsWithPlaceholder = Array(retItems[ 0 ..< index])
        self.itemsWithPlaceholder.append(nil)
        self.itemsWithPlaceholder += Array(retItems[ index ..< retItems.count])
    }
    func removePlaceholder(widgetDragging: LayoutWidget) {
        var retItems = self.items
        if let index = retItems.firstIndex(of: widgetDragging) {
            retItems.remove(at: index)
        }
        self.itemsWithPlaceholder = retItems
    }
    
    func setPredictedDropIndex(value: DragGesture.Value, widgetDragging: LayoutWidget) {
        var nodes: [Float] = []
        
        for item in self.items {
            if !self.items.contains(widgetDragging) {
                nodes.append(Float(item.rect!.minX) - 5)
            } else if value.translation.width < 0 {
                nodes.append(Float(item.rect!.minX) - 5)
            } else {
                nodes.append(Float(item.rect!.maxX) + 5)
            }
        }
        if !self.items.contains(widgetDragging) && !self.items.isEmpty {
            nodes.append(Float(self.items.last!.rect!.maxX) + 5)
        }
        
        let comparisonX = Float(widgetDragging.rect!.origin.x + value.translation.width)
                        + Float(widgetDragging.rect!.width) / 2.0

        if let closest = nodes.enumerated().min(by: {
            abs($0.element - comparisonX) < abs($1.element - comparisonX)
        }) {
            self.predictedDropIndex = closest.offset
        }
    }
}
