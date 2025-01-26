//
//  InteractionBarEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 18/08/2024.
//

import SwiftUI

extension InteractionBarEditorView {
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
    class BarItem {
        let item: Configuration.Item?
        var active: Bool
        var visible: Bool
        
        let uuid: UUID = .init()
        
        init(item: Configuration.Item?, active: Bool, visible: Bool) {
            self.item = item
            self.active = active
            self.visible = visible
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
        items.reduce(0) { $0 + ($1?.score ?? 0) }
    }
    
    var showInfoCapsule: Bool { !allowNewItemInsertion || trayPickedUpItem != nil }
    
    func addToBar(_ item: Configuration.Item, at index: Int) {
        // remove from tray if present
        let trayItem = trayItems.first(where: { $0.item == item })
        assert(trayItem != nil, "Tray item is nil!")
        trayItem?.selected = true
        
        barItems.insert(.init(item: item, active: false, visible: true), at: index)
        
        // small delay prevents animation hitch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            withAnimation(.easeInOut(duration: barAnimationDuration)) {
                barItems[index].active = true
            }
        }
        
        // update items array
        items = barItems.map(\.item)
    }
    
    func moveOnBar(from sourceIndex: Int, to targetIndex: Int) {
        let adjustedSourceIndex: Int = sourceIndex > targetIndex ? sourceIndex + 1 : sourceIndex
        let item = barItems[sourceIndex]
        let newItem: BarItem = .init(item: item.item, active: false, visible: true)
        
        barItems.insert(newItem, at: targetIndex)
        item.visible = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            withAnimation(.easeInOut(duration: barAnimationDuration)) {
                newItem.active = true
                item.active = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.remove(at: adjustedSourceIndex)
        }
        
        items = barItems.map(\.item)
    }
    
    func removeFromBar(at index: Int) {
        guard index < barItems.count else { return }
                
        // set un-selected on tray
        let trayItem = trayItems.first(where: { $0.item == barItems[index].item })
        assert(trayItem != nil, "Tray item is nil!")
        trayItem?.selected = false
        
        // hide on the bar
        barItems[index].visible = false
        withAnimation(.easeInOut(duration: barAnimationDuration)) {
            barItems[index].active = false
        }
        
        // remove from bar and update items
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimationDuration) {
            barItems.remove(at: index)
            items = barItems.map(\.item)
        }
    }
    
    // Where `nil` represents the info stack
    var items: [Configuration.Item?] {
        get { configuration.leading + [nil] + configuration.trailing }
        nonmutating set {
            guard let infoStackIndex = newValue.firstIndex(of: nil) else {
                assertionFailure()
                return
            }
            configuration = .init(
                leading: newValue[..<infoStackIndex].compactMap { $0 },
                trailing: newValue[infoStackIndex...].compactMap { $0 },
                readouts: configuration.readouts
            )
        }
    }
    
    func barItemDragGesture(index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                barPickedUpIndex = index
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
                trayPickedUpItem = item
                dragLocation = gesture.location
                dragTranslation = gesture.translation
            }
            .onEnded { _ in
                completeDrag()
            }
    }
    
    func completeDrag() {
        defer {
            self.barPickedUpIndex = nil
            self.hoveredDropLocation = nil
            self.trayPickedUpItem = nil
        }
        
        guard let hoveredDropLocation else { return }
        
        if let barPickedUpIndex {
            switch hoveredDropLocation {
            case let .bar(index: dropIndex):
                moveOnBar(from: barPickedUpIndex, to: dropIndex)
            case .tray:
                removeFromBar(at: barPickedUpIndex)
            }
        } else if let trayPickedUpItem {
            switch hoveredDropLocation {
            case let .bar(index: dropIndex):
                addToBar(trayPickedUpItem, at: dropIndex)
            default: break
            }
        }
    }
    
    func trayItemOutlineColor(_ item: Configuration.Item) -> Color {
        if let barPickedUpIndex, hoveredDropLocation == .tray, barPickedUpIndex < items.count, items[barPickedUpIndex] == item {
            return palette.accent
        }
        return palette.tertiary
    }
}
