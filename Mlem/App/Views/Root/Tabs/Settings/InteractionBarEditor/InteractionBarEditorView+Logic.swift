//
//  InteractionBarEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 18/08/2024.
//

import SwiftUI

extension InteractionBarEditorView {
    // MARK: - Definitions
    
    enum ConfigurationType {
        case post, comment
    }
    
    enum DropLocation: Equatable {
        case bar(Int)
        case tray
        
        var index: Int? {
            switch self {
            case let .bar(index): index
            default: nil
            }
        }
    }
    
    @Observable
    class TrayItem: Equatable {
        let item: Configuration.Item
        
        private(set) var opacity: CGFloat
        
        init(item: Configuration.Item, visible: Bool) {
            self.item = item
            self.opacity = visible ? 1 : 0
        }
        
        /// Toggles opacity to 1
        func show() { opacity = 1 }
        
        /// Toggles opacity to 0
        func hide() { opacity = 0 }
        
        static func == (lhs: TrayItem, rhs: TrayItem) -> Bool {
            lhs.item == rhs.item
        }
    }
     
    @Observable
    class BarItem: Equatable {
        let item: Configuration.Item?
        
        /// Controls the width of the barItem view
        private(set) var maxWidth: CGFloat?
        
        /// Controls the opacity of the barItem view
        private(set) var opacity: CGFloat
        
        /// If this BarItem is replacing another one (i.e., when moving a widget on the bar), this points to the old
        /// BarItem, allowing the barItem view to smoothly animate the ancestor out when it appears.
        weak var ancestor: BarItem?
        
        /// Uniquely identifies this BarItem. This is needed to allow two `BarItem`s with the same `item`
        /// to exist at once on the bar (used when moving bar items) without relying on index-based identification
        let uuid: UUID = .init()
        
        init(item: Configuration.Item?, expanded: Bool, visible: Bool, ancestor: BarItem? = nil) {
            self.item = item
            self.maxWidth = expanded ? nil : 0
            self.opacity = visible ? 1 : 0
            self.ancestor = ancestor
        }
        
        /// Expands maxWidth to default
        func expand() { maxWidth = nil }
        
        /// Reduces maxWidth to 0
        func collapse() { maxWidth = 0 }
        
        /// Toggles opacity to 1
        func show() { opacity = 1 }
        
        /// Toggles opacity to 0
        func hide() { opacity = 0 }
        
        static func == (lhs: BarItem, rhs: BarItem) -> Bool {
            lhs.uuid == rhs.uuid
        }
    }
    
    // MARK: - Helper Computed Vars
    
    var allowNewItemInsertion: Bool {
        if let trayPickedUpItem {
            let currentScore = barItems.reduce(0) { $0 + ($1.item?.score ?? 0) }
            return currentScore + trayPickedUpItem.item.score <= 6
        }
        return true
    }
    
    var showInfoCapsule: Bool { !allowNewItemInsertion || trayPickedUpItem != nil }
    
    var isDraggingItem: Bool { trayPickedUpItem != nil || barPickedUpItem != nil }
    
    var barPickedUpIndex: Int? { barPickedUpItem?.index }
    
    // MARK: - Drag Gestures
    
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
    
    func trayItemDragGesture(trayItem: TrayItem) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                if trayPickedUpItem == nil, !barItems.contains(where: { $0.item == trayItem.item }) {
                    HapticManager.main.play(haptic: .firmInfo, priority: .low)
                    trayPickedUpItem = trayItem
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
            self.dropLocation = nil
            self.trayPickedUpItem = nil
        }
        
        guard let dropLocation else { return }
  
        if let trayPickedUpItem {
            guard case let .bar(targetIndex) = dropLocation else { return }
            addToBar(trayPickedUpItem, at: targetIndex)
        } else if let barPickedUpItem {
            switch dropLocation {
            case let .bar(targetIndex):
                moveOnBar(barItem: barPickedUpItem.barItem, from: barPickedUpItem.index, to: targetIndex)
            case .tray:
                removeFromBar(barItem: barPickedUpItem.barItem)
            }
        }
    }
    
    // MARK: - State Updates
    
    func addToBar(_ trayItem: TrayItem, at index: Int) {
        guard allowNewItemInsertion,
              !barItems.contains(where: { $0.item == trayItem.item }) else {
            assertionFailure(!allowNewItemInsertion ? "Item insertion disabled" : "Item already in bar")
            return
        }
        
        HapticManager.main.play(haptic: .firmInfo, priority: .high)

        let newItem: BarItem = .init(item: trayItem.item, expanded: false, visible: true)
        barItems.insert(newItem, at: index)
        trayItem.hide()
        
        updateConfiguration()
    }
  
    func moveOnBar(barItem: BarItem, from sourceIndex: Int, to targetIndex: Int) {
        // noop on move to current location or immediately after current location
        guard targetIndex != sourceIndex, targetIndex != sourceIndex + 1 else { return }
        
        HapticManager.main.play(haptic: .firmInfo, priority: .high)
        
        let newItem: BarItem = .init(item: barItem.item, expanded: false, visible: true, ancestor: barItem)
        barItem.hide()
        
        if targetIndex == barItems.count {
            barItems.append(newItem)
        } else {
            barItems.insert(newItem, at: targetIndex)
        }
        
        // wait for animation to complete, then remove original item from barItems
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.removeAll(where: { $0 == barItem })
            updateConfiguration()
        }
    }
    
    func removeFromBar(barItem: BarItem) {
        // no removing the info stack
        guard let item = barItem.item else { return }
        let trayItem = trayItems.first(where: { $0.item == item })
        
        HapticManager.main.play(haptic: .firmInfo, priority: .high)
        
        // smoothly animate away
        barItem.hide()
        withAnimation(.easeInOut(duration: barAnimationDuration)) {
            trayItem?.show()
            barItem.collapse()
        }
        
        // wait for animation to complete, then remove from barItems
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.removeAll(where: { $0 == barItem })
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        guard let infoStackIndex = barItems.firstIndex(where: { $0.item == nil }) else {
            assertionFailure("Could not find info stack in barItems")
            return
        }
        configuration = .init(
            leading: barItems[..<infoStackIndex].compactMap(\.item),
            trailing: barItems[infoStackIndex...].compactMap(\.item),
            readouts: configuration.readouts,
            availableWidgets: configuration.availableWidgets
        )
    }
    
    // MARK: - Helpers
    
    func trayItemOutlineColor(_ trayItem: TrayItem) -> Color {
        if let dropLocation,
           trayPickedUpItem == trayItem || (barPickedUpItem?.barItem.item == trayItem.item && dropLocation == .tray) {
            return palette.accent
        }
        return palette.tertiary
    }
}
