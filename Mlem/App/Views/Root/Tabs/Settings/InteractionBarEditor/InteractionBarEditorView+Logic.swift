//
//  InteractionBarEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 18/08/2024.
//

import SwiftUI

extension InteractionBarEditorView {
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
    
    func barItemDragGesture(index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("editor"))
            .onChanged { gesture in
                barPickedUpIndex = index
                dragLocation = gesture.location
                dragTranslation = gesture.translation
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.1)) {
                    completeDrag()
                    dragTranslation = .zero
                }
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
                withAnimation(.easeOut(duration: 0.1)) {
                    completeDrag()
                    dragTranslation = .zero
                }
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
                var newItems = items
                let item = newItems.remove(at: barPickedUpIndex)
                let newIndex = dropIndex > barPickedUpIndex ? dropIndex - 1 : dropIndex
                newItems.insert(item, at: newIndex)
                items = newItems
            case .tray:
                if items[barPickedUpIndex] != nil {
                    items.remove(at: barPickedUpIndex)
                }
            }
        } else if let trayPickedUpItem {
            switch hoveredDropLocation {
            case let .bar(index: dropIndex):
                items.insert(trayPickedUpItem, at: dropIndex)
            default: break
            }
        }
    }
    
    func trayItemOutlineColor(_ item: Configuration.Item) -> Color {
        if let barPickedUpIndex, items[barPickedUpIndex] == item, hoveredDropLocation == .tray {
            return palette.accent
        }
        return palette.secondaryGroupedBackground
    }
}
