//
//  WidgetModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import SwiftUI

indirect enum WidgetType: Hashable {
    case placeholder(wrappedValue: WidgetType)
    case spacer
    case upvote
    case downvote
    case save
    case reply
    
    var width: CGFloat {
        switch self {
        case .placeholder(let wrappedValue):
            return wrappedValue.width
        case .spacer:
            return .infinity
        case .upvote:
            return 40
        case .downvote:
            return 40
        case .save:
            return 40
        case .reply:
            return 40
        }
        
    }
}

struct PostLayoutWidget: Equatable, Hashable {
    var type: WidgetType
    var rect: CGRect?
    
    init(_ type: WidgetType) {
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
    
    static func == (lhs: PostLayoutWidget, rhs: PostLayoutWidget) -> Bool {
        return lhs.type == rhs.type
    }
}

enum WidgetDropLocation: Equatable {
    case bar(index: Int)
    case tray
}

class LayoutWidgetModel: ObservableObject {
    
    private(set) var items: [PostLayoutWidget] = .init()
    
    @Published private(set) var itemsWithPlaceholder: [PostLayoutWidget] = .init()
    @Published var trayY: CGFloat = 0
    
    @Published var widgetDragging: PostLayoutWidget?
    @Published var lastDraggedWidget: PostLayoutWidget?
    @Published var predictedDropLocation: WidgetDropLocation?
    
    @Published var widgetDraggingOffset = CGSize.zero

    init() {
        self.items = [
            .init(.upvote),
            .init(.downvote),
            .init(.spacer),
            .init(.save),
            .init(.reply)
        ]
        updateItemsWithPlaceholder()
    }
    
    var shouldShowDraggingWidget: Bool {
        widgetDraggingOffset != CGSize.zero && widgetDragging != nil
    }
    
    func updateItemsWithPlaceholder() {
        switch predictedDropLocation {
        case .bar(let index):
            var retItems = self.items
            retItems.remove(at: retItems.firstIndex(of: widgetDragging!)!)
            self.itemsWithPlaceholder = Array(
                retItems[ 0 ..< index]
                + [PostLayoutWidget(.placeholder(wrappedValue: widgetDragging!.type))]
                + retItems[ index ..< retItems.count]
            )
        case .tray:
            var retItems = self.items
            retItems.remove(at: retItems.firstIndex(of: widgetDragging!)!)
            self.itemsWithPlaceholder = retItems
        case nil:
            self.itemsWithPlaceholder = self.items
        }
    }
    
    func setWidgetDragging(_ value: DragGesture.Value) {
        if widgetDragging == nil {
            self.widgetDragging = getItemAtLocation(value.location)
        }
        
        if widgetDragging != nil {
            
            widgetDraggingOffset = CGSize(
                width: widgetDragging!.rect!.origin.x
                + value.translation.width + 10,
                height: widgetDragging!.rect!.origin.y
                + value.translation.height + 100
            )
            
            if value.location.y > trayY {
                self.predictedDropLocation = .tray
            } else if value.translation.width != 0 {
                if predictedDropLocation == nil {
                    self.predictedDropLocation = .bar(index: 0)
                }
                var nodes: [Float] = []
                for item in self.items {
                    if value.translation.width < 0 {
                        nodes.append(Float(item.rect!.minX) + 5)
                    } else {
                        nodes.append(Float(item.rect!.maxX) + 15)
                    }
                }
                let comparisonX = Float(widgetDraggingOffset.width) + Float(widgetDragging!.rect!.width) / 2.0

                let closest = nodes.enumerated().min(by: {
                    abs($0.element - comparisonX) < abs($1.element - comparisonX)
                })
                self.predictedDropLocation = .bar(index: closest!.offset)
            }
            updateItemsWithPlaceholder()
        }
    }
    
    func dropWidget() {
        widgetDraggingOffset = .zero
        
        switch predictedDropLocation {
        case .bar(let index):
            removeItem(widgetDragging!)
            addItem(widgetDragging!, index: index)
            
        case .tray:
            removeItem(widgetDragging!)
        case nil:
            break
        }
        lastDraggedWidget = widgetDragging
        widgetDragging = nil
        predictedDropLocation = nil
        updateItemsWithPlaceholder()
    }
    
    func setItemRect(_ item: PostLayoutWidget, _ rect: CGRect) {
        self.items[self.items.firstIndex(of: item)!].rect = rect
    }
    
    func addItem(_ item: PostLayoutWidget, index: Int) {
        self.items.insert(item, at: index)
    }
    
    func removeItem(_ item: PostLayoutWidget) {
        self.items.remove(at: self.items.firstIndex(of: item)!)
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
