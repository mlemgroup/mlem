//
//  InteractionBarEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 18/08/2024.
//

import SwiftUI

extension InteractionBarEditorView {
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
                let item = items.remove(at: barPickedUpIndex)
                let newIndex = dropIndex > barPickedUpIndex ? dropIndex - 1 : dropIndex
                items.insert(item, at: newIndex)
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
