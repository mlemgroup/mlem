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
        
        var offset: Int {
            switch self {
            case .left: 0
            case .right: 1
            }
        }
    }
    
    enum DropLocation: Equatable {
        // swiftlint:disable:next identifier_name
        case bar(Side, of: BarItem)
        case tray
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
            return itemsTotalScore + trayPickedUpItem.score <= 6
        }
        return true
    }
    
    var itemsTotalScore: Int {
        barItems.reduce(0) { $0 + ($1.item?.score ?? 0) }
    }
    
    var showInfoCapsule: Bool { !allowNewItemInsertion || trayPickedUpItem != nil }
    
    var isDraggingItem: Bool { trayPickedUpItem != nil || barPickedUpItem != nil }
    
    var barPickedUpIndex: Int? { barPickedUpItem?.index }
    
    func addToBar(_ item: Configuration.Item, at index: Int) {
        guard allowNewItemInsertion,
              !barItems.contains(where: { $0.item == item }) else {
            // TODO: this triggers if you keep trying to add things to a full bar
            assertionFailure(
                !allowNewItemInsertion ? "Item insertion disabled" : "Item already in bar"
            )
            return
        }
        
        HapticManager.main.play(haptic: .firmInfo, priority: .high)

        let newItem: BarItem = .init(item: item, active: false, visible: true)
        barItems.insert(newItem, at: index)
        
        updateConfiguration()
    }
  
    func moveOnBar(item: BarItem, from sourceIndex: Int, to targetIndex: Int) {
        // noop on move to current location or immediately after current location
        guard targetIndex != sourceIndex, targetIndex != sourceIndex + 1 else { return }
        
        HapticManager.main.play(haptic: .firmInfo, priority: .high)
        
        let newItem: BarItem = .init(item: item.item, active: false, visible: true, ancestor: item)
        item.visible = false
        
        if targetIndex == barItems.count {
            barItems.append(newItem)
        } else {
            barItems.insert(newItem, at: targetIndex)
        }
        
        // wait for animation to complete, then remove original item from barItems
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.removeAll(where: { $0 == item })
            updateConfiguration()
        }
    }
    
    func removeFromBar(item: BarItem) {
        // no removing the info stack
        guard item.item != nil else { return }
        
        HapticManager.main.play(haptic: .firmInfo, priority: .high)
        
        // hide on the bar
        item.visible = false
         withAnimation(.easeInOut(duration: barAnimationDuration)) {
             item.active = false
        }
        
        // wait for animation to complete, then remove from barItems
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.removeAll(where: { $0 == item })
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        guard let infoStackIndex = barItems.firstIndex(where: { $0.item == nil }) else {
            assertionFailure("Could not find info stack in barItems")
            return
        }
        configuration = .init(
            leading: barItems[..<infoStackIndex].compactMap { $0.item },
            trailing: barItems[infoStackIndex...].compactMap { $0.item },
            readouts: configuration.readouts
        )
    }
  
    func barItemDragGesture(item: BarItem, index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                if barPickedUpItem == nil {
                    HapticManager.main.play(haptic: .firmInfo, priority: .low)
                    barPickedUpItem = (item, index)
                }
                dragLocation = gesture.location
                dragTranslation = gesture.translation
            }
            .onEnded { _ in
                completeDrag()
            }
    }
    
    func trayItemDragGesture(item: Configuration.Item) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                if trayPickedUpItem == nil, !barItems.contains(where: { $0.item == item }) {
                    HapticManager.main.play(haptic: .firmInfo, priority: .low)
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
            self.hoveredDropIndex = nil
            self.trayPickedUpItem = nil
        }
        
        guard let hoveredDropIndex else { return }
  
        if let trayPickedUpItem {
            guard hoveredDropIndex >= 0 else { return }
            addToBar(trayPickedUpItem, at: hoveredDropIndex)
        } else if let barPickedUpItem {
            if hoveredDropIndex < 0 {
                removeFromBar(item: barPickedUpItem.item)
            } else {
                // guard let sourceIndex = barIndex(of: barPickedUpItem) else { return }
                // guard let barPickedUpItem else { return }
                moveOnBar(item: barPickedUpItem.item, from: barPickedUpItem.index, to: hoveredDropIndex)
            }
        }
    }
    
    /// Helper function to find the given item in barItems and assertionFailure if not found
    func barIndex(of item: BarItem) -> Int? {
        guard let ret = barItems.firstIndex(of: item) else {
            assertionFailure("Could not find \(item.uuid) in barItems")
            return nil
        }
        return ret
    }
    
    func trayItemOutlineColor(_ item: Configuration.Item) -> Color {
        return trayPickedUpItem == item ||
        (barPickedUpItem?.item.item == item && (hoveredDropIndex ?? 1) < 0) ?
        palette.accent : palette.tertiary
    }
}
