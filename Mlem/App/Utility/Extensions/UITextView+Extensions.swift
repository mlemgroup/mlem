//
//  UITextView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import UIKit

extension UITextView {
    func wrapSelectionWithDelimiters(_ delimiter: String) {
        if let range = selectedTextRange, let text = text(in: range) {
            if range.start == range.end {
                let checkStart = position(from: range.start, offset: -delimiter.count)
                let checkEnd = position(from: range.end, offset: delimiter.count)
                
                // Checking for delimiters on both sides of the cursor, in which case the delimiters are removed
                if let checkStart, let checkEnd, let checkRange = textRange(from: checkStart, to: checkEnd) {
                    if self.text(in: checkRange) == delimiter + delimiter {
                        // Removing delimiters around the cursor
                        replace(checkRange, withText: "")
                        return
                    }
                }
                
                // Checking for delimiters on the trailing side, in which case the cursor is moved to after the delimiters
                if let checkEnd, let checkRange = textRange(from: range.end, to: checkEnd) {
                    if self.text(in: checkRange) == delimiter {
                        selectedTextRange = textRange(from: checkEnd, to: checkEnd)
                        return
                    }
                }
                
                // If no surrounding delimiters are detected, add some
                replace(range, withText: delimiter + text + delimiter)
                if let newPosition = position(from: range.start, offset: delimiter.count) {
                    selectedTextRange = textRange(from: newPosition, to: newPosition)
                }
            } else {
                if text.hasPrefix(delimiter), text.hasSuffix(delimiter) {
                    // If delimiters are detected in selection, remove them
                    replace(range, withText: String(text.dropLast(delimiter.count).dropFirst(delimiter.count)))
                    if let newEnd = position(from: range.end, offset: -delimiter.count * 2) {
                        selectedTextRange = textRange(from: range.start, to: newEnd)
                    }
                } else {
                    // Otherwise, wrap the selection in delimiters
                    replace(range, withText: delimiter + text + delimiter)
                    if let newEnd = position(from: range.end, offset: delimiter.count * 2) {
                        selectedTextRange = textRange(from: range.start, to: newEnd)
                    }
                }
            }
        }
    }
    
    func wrapSelectionWithSpoiler() {
        if let range = selectedTextRange, let text = text(in: range) {
            let atStart = range.start == beginningOfDocument
            let atEnd = range.end == endOfDocument
            let newText = "\(atStart ? "" : "\n")::: spoiler Spoiler\n\(text)\n:::\(atEnd ? "" : "\n")"
            replace(range, withText: newText)
            if let newPosition = position(from: range.start, offset: 20 + text.count) {
                selectedTextRange = textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    func toggleQuoteAtCursor() {
        if let range = selectedTextRange, let text = text(in: range) {}
    }
}
