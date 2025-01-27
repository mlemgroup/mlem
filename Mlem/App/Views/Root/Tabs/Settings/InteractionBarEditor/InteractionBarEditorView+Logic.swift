//
//  InteractionBarEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 18/08/2024.
//

import SwiftUI

extension InteractionBarEditorView {
    enum Side {
        case left, right
    }
    
    enum NewDropLocation: Equatable {
        case bar(Side, of: BarItem)
//        case left(BarItem)
//        case right(BarItem)
        case tray
        
//        var item: BarItem? {
//            switch self {
//            case let .left(barItem), let .right(barItem):
//                barItem
//            default:
//                nil
//            }
//        }
    }
    
    @Observable
    class TrayItem {
        let item: Configuration.Item
        var selected: Bool
        
        init(item: Configuration.Item, selected: Bool) {
            self.item = item
            self.selected = selected
        }
    }
    
    @Observable
    class BarItem: Equatable {
        let item: Configuration.Item?
        var active: Bool
        var visible: Bool
        weak var ancestor: BarItem?
        
        let uuid: UUID = .init()
        
        init(item: Configuration.Item?, active: Bool, visible: Bool, ancestor: BarItem? = nil) {
            self.item = item
            self.active = active
            self.visible = visible
            self.ancestor = ancestor
        }
        
        static func == (lhs: BarItem, rhs: BarItem) -> Bool {
            lhs.uuid == rhs.uuid
        }
    }
    
    var allowNewItemInsertion: Bool {
        if let trayPickedUpItem {
            if itemsTotalScore + trayPickedUpItem.score > 6 {
                return false
            }
        }
        return true
    }
    
    var itemsTotalScore: Int {
        // items.reduce(0) { $0 + ($1?.score ?? 0) }
        barItems.reduce(0) { $0 + ($1.item?.score ?? 0) }
    }
    
    var showInfoCapsule: Bool { !allowNewItemInsertion || trayPickedUpItem != nil }
    
    func addToBar(_ item: Configuration.Item, at index: Int) {
        guard allowNewItemInsertion else { return }
        
        // remove from tray if present
        let trayItem = trayItems.first(where: { $0.item == item })
        assert(trayItem != nil, "Tray item is nil!")
        trayItem?.selected = true
        
        let newItem: BarItem = .init(item: item, active: false, visible: true)
        barItems.insert(newItem, at: index)
        
        // updateConfiguration()
    }
  
    func moveOnBar(item: BarItem, from sourceIndex: Int, to targetIndex: Int) {
        guard sourceIndex != targetIndex, sourceIndex != targetIndex - 1 else {
            print("noop")
            return
        }
        
        let newItem: BarItem = .init(item: item.item, active: false, visible: true, ancestor: item)
        item.visible = false
        
        // insert newItem into barItems, or append if needed
        if targetIndex == barItems.count {
            barItems.append(newItem)
        } else {
            barItems.insert(newItem, at: targetIndex)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            print("DEBUG removing all \(item.uuid)")
            barItems.removeAll(where: { $0 == item })
            print("DEBUG removed all \(item.uuid)")
        }
    }
    
    func removeFromBar(at index: Int) {
        guard let barItem = barItems[safeIndex: index], barItem.item != nil else { return }
                
        // set un-selected on tray
//        let trayItem = trayItems.first(where: { $0.item == barItems[index].item })
//        assert(trayItem != nil, "Tray item is nil!")
//        trayItem?.selected = false
        
        // hide on the bar
        barItem.visible = false
         withAnimation(.easeInOut(duration: barAnimationDuration)) {
            barItem.active = false
        }
        
        // remove from bar and update items
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.remove(at: index)
        }
        
        // updateConfiguration()
    }
    
    func updateConfiguration() {
        guard let infoStackIndex = barItems.firstIndex(where: { $0.item == nil }) else {
            assertionFailure()
            return
        }
        configuration = .init(
            leading: barItems[..<infoStackIndex].filter(\.active).compactMap { $0.item },
            trailing: barItems[infoStackIndex...].filter(\.active).compactMap { $0.item },
            readouts: configuration.readouts
        )
    }
  
    func barItemDragGesture(item: BarItem) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                if barPickedUpItem == nil {
                    barPickedUpItem = item
                }
                dragLocation = gesture.location
                dragTranslation = gesture.translation
            }
            .onEnded { _ in
                completeDrag()
            }
    }
    
//    func barItemDragGesture(index: Int) -> some Gesture {
//        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
//            .onChanged { gesture in
//                barPickedUpIndex = index
//                dragLocation = gesture.location
//                dragTranslation = gesture.translation
//            }
//            .onEnded { _ in
//                completeDrag()
//            }
//    }
    
    func trayItemDragGesture(item: Configuration.Item) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                if trayPickedUpItem == nil {
                    trayPickedUpItem = item
                }
                dragLocation = gesture.location
                dragTranslation = gesture.translation
            }
            .onEnded { _ in
                completeDrag()
            }
    }
    
    func completeDrag() {
        defer {
            self.barPickedUpItem = nil
            self.newHoveredDropLocation = nil
            self.hoveredDropLocation = nil
            self.trayPickedUpItem = nil
        }
  
        if let trayPickedUpItem {
            guard let newHoveredDropLocation,
                  let barItem = newHoveredDropLocation.item,
                  let baseIndex = barItems.firstIndex(of: barItem) else {
                print("DEBUG could not find drop target")
                return
            }
            
            switch newHoveredDropLocation {
            case .left: addToBar(trayPickedUpItem, at: baseIndex)
            case .right: addToBar(trayPickedUpItem, at: baseIndex + 1)
            default: break
            }
        } else if let barPickedUpItem {
            guard let sourceIndex = barItems.firstIndex(of: barPickedUpItem) else {
                assertionFailure("Could not find source item in barItems")
                return
            }
            
            // if hovering over bar, move item, otherwise drop to tray
            if let dropItem = newHoveredDropLocation?.item {
                guard let baseTargetIndex = barItems.firstIndex(of: dropItem) else {
                    print("DEBUG no valid target available")
                    return
                }
                
                switch newHoveredDropLocation {
                case .left:
                    moveOnBar(item: barPickedUpItem, from: sourceIndex, to: baseTargetIndex)
                case .right:
                    moveOnBar(item: barPickedUpItem, from: sourceIndex, to: baseTargetIndex + 1)
                default:
                    assertionFailure("Unreachable code")
                    return
                }
            } else {
                removeFromBar(at: sourceIndex)
            }
        }
    }
    
    func trayItemOutlineColor(_ item: Configuration.Item) -> Color {
//        if let barPickedUpIndex, hoveredDropLocation == .tray, barPickedUpIndex < barItems.count, barItems[barPickedUpIndex].item == item {
//            return palette.accent
//        }
        return palette.tertiary
    }
}
