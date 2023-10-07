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
    var itemsToRender: [LayoutWidget?] { items }
    var rect: CGRect?
    
    init(_ items: [LayoutWidget]) {
        _items = Published(wrappedValue: items)
    }
    
    func update(isHovered: Bool, value: DragGesture.Value, widgetDragging: LayoutWidget) {}
    
    func removeFrom(_ widget: LayoutWidget) { }
    
    func addTo(_ widget: LayoutWidget) { }
    
    func getItemAtLocation(_ location: CGPoint) -> LayoutWidget? {
        items.first { $0.rect?.contains(location) ?? false }
    }
    
    func isValidDropLocation(_ widgetDragging: LayoutWidget? = nil) -> Bool { true }
    
    func getItemDictionary() -> [LayoutWidgetType: LayoutWidget] {
        itemsToRender.reduce(into: [LayoutWidgetType: LayoutWidget]()) { dict, widget in
            if let widget {
                dict[widget.type] = widget
            }
        }
    }
    
    static func == (lhs: LayoutWidgetCollection, rhs: LayoutWidgetCollection) -> Bool {
        lhs.id == rhs.id
    }
}

class InfiniteWidgetCollection: LayoutWidgetCollection {
    override func getItemAtLocation(_ location: CGPoint) -> LayoutWidget? {
        if let widget = items.first(where: { $0.rect?.contains(location) ?? false }) {
            return LayoutWidget(widget.type, rect: widget.rect)
        } else {
            return nil
        }
    }
}

class FiniteWidgetCollection: LayoutWidgetCollection {
    var costLimit: Float
    
    init(_ items: [LayoutWidget], costLimit: Float = .infinity) {
        self.costLimit = costLimit
        super.init(items)
    }
    
    override func addTo(_ widget: LayoutWidget) {
        items.append(widget)
    }
    
    override func removeFrom(_ widget: LayoutWidget) {
        if let index = items.firstIndex(of: widget) {
            items.remove(at: index)
        }
    }
    
    override func isValidDropLocation(_ widgetDragging: LayoutWidget? = nil) -> Bool {
        // costLimit == .infinity is for optimisation
        costLimit == .infinity || totalCost(widgetDragging) <= costLimit
    }
    
    func totalCost(_ widgetDragging: LayoutWidget? = nil) -> Float {
        items.reduce(0) { accumulator, element in
            accumulator + element.type.cost
        } + (widgetDragging?.type.cost ?? 0)
    }
}

class UnorderedWidgetCollection: FiniteWidgetCollection {}

class OrderedWidgetCollection: FiniteWidgetCollection {
    @Published var itemsWithPlaceholder: [LayoutWidget?] = .init()
    override var itemsToRender: [LayoutWidget?] { itemsWithPlaceholder }
    var predictedDropIndex: Int?
    
    override init(_ items: [LayoutWidget], costLimit: Float = .infinity) {
        super.init(items, costLimit: costLimit)
        self.itemsWithPlaceholder = self.items
    }
    
    override func update(isHovered: Bool, value: DragGesture.Value, widgetDragging: LayoutWidget) {
        if isHovered {
            if value.translation.width == 0, items.contains(widgetDragging) {
                predictedDropIndex = items.firstIndex(of: widgetDragging)
            } else {
                predictedDropIndex = computeDropIndex(value: value, widgetDragging: widgetDragging)
            }
            if let predictedDropIndex {
                updatePlaceholderPosition(widgetDragging: widgetDragging, index: predictedDropIndex)
            }
        } else {
            removePlaceholder(widgetDragging: widgetDragging)
        }
    }
    
    override func addTo(_ widget: LayoutWidget) {
        items.insert(widget, at: predictedDropIndex!)
        itemsWithPlaceholder = items
    }
    
    func updatePlaceholderPosition(widgetDragging: LayoutWidget, index: Int) {
        var retItems = items
        if let widgetDraggingIndex = retItems.firstIndex(of: widgetDragging) {
            retItems.remove(at: widgetDraggingIndex)
        }
        itemsWithPlaceholder = Array(retItems[0 ..< index])
        itemsWithPlaceholder.append(nil)
        itemsWithPlaceholder += Array(retItems[index ..< retItems.count])
    }

    func removePlaceholder(widgetDragging: LayoutWidget) {
        var retItems = items
        if let index = retItems.firstIndex(of: widgetDragging) {
            retItems.remove(at: index)
        }
        itemsWithPlaceholder = retItems
    }
    
    func computeDropIndex(value: DragGesture.Value, widgetDragging: LayoutWidget) -> Int? {
        var nodes: [Float] = []
        
        for item in items {
            if let rect = item.rect {
                if !items.contains(widgetDragging) {
                    nodes.append(Float(rect.minX) - 5)
                } else if value.translation.width < 0 {
                    nodes.append(Float(rect.minX) - 5)
                } else {
                    nodes.append(Float(rect.maxX) + 5)
                }
            }
        }
        if !items.contains(widgetDragging), let lastRect = items.last?.rect {
            nodes.append(Float(lastRect.maxX) + 5)
        }
        
        if let rect = widgetDragging.rect {
            let comparisonX = Float(rect.origin.x + value.translation.width)
            + Float(widgetDragging.rect!.width) / 2.0
            
            if let closest = nodes.enumerated().min(by: {
                abs($0.element - comparisonX) < abs($1.element - comparisonX)
            }) {
                return closest.offset
            }
        } else {
            print("Widget computeDropIndex failure")
        }
        return nil
    }
}
