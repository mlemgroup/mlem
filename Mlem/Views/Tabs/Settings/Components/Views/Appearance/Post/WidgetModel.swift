//
//  WidgetModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2023.
//

import Foundation

enum WidgetType: String {
    case one = "1"
    case two = "2"
    case three = "3"
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

class LayoutWidgetModel: ObservableObject {
    
    private(set) var items: [PostLayoutWidget] = .init()

    init() {
        self.items = [.init(.one), .init(.two), .init(.three)]
    }
    
    var enumeratedItems: [(offset: Int, element: PostLayoutWidget)] {
        Array(items.enumerated())
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
