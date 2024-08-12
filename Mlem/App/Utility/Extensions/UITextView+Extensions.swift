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
        toggleLinePrefix(prefix: "> ")
    }
    
    func toggleHeadingAtCursor(level: Int) {
        guard 1 ... 6 ~= level else {
            assertionFailure()
            return
        }
        toggleLinePrefix(prefix: String(repeating: "#", count: level) + " ")
    }
    
    // swiftlint:disable:next function_body_length
    private func toggleLinePrefix(prefix: String) {
        if let selectedTextRange, let selectedText = text(in: selectedTextRange) {
            if let firstTargetedNewLineIndex = findLastNewlineIndex(),
               let lookBehindRange = textRange(from: beginningOfDocument, to: selectedTextRange.start) {
                // Remove "> " if exists
                var allText = text ?? ""
                if let endIndex = allText.index(firstTargetedNewLineIndex, offsetBy: prefix.count, limitedBy: allText.endIndex) {
                    if allText[firstTargetedNewLineIndex ..< endIndex] == prefix {
                        let selectedEndIndex = allText.index(
                            allText.endIndex,
                            offsetBy: offset(from: selectedTextRange.end, to: selectedTextRange.end)
                        )
                        allText = allText.replacingOccurrences(
                            of: "\n\(prefix)", with: "\n", range: firstTargetedNewLineIndex ..< selectedEndIndex
                        )
                        allText.removeSubrange(firstTargetedNewLineIndex ..< endIndex)
                        
                        var startDistance = 0
                        if let startIndex = stringIndex(from: selectedTextRange.start) {
                            // Avoid fatalError from `distance()`
                            if startIndex > allText.endIndex {
                                startDistance = prefix.count
                            } else {
                                startDistance = allText.distance(from: firstTargetedNewLineIndex, to: startIndex)
                            }
                        }
                        
                        let newStart = position(
                            from: selectedTextRange.start,
                            offset: -min(startDistance, prefix.count)
                        ) ?? beginningOfDocument
                        let newEnd = position(
                            from: selectedTextRange.end,
                            offset: allText.count - text.count
                        ) ?? endOfDocument
                        
                        text = allText
                        self.selectedTextRange = textRange(from: newStart, to: newEnd)
                        return
                    }
                }
                
                // Insert "> " if it doesn't exist
                
                guard var lookBehindText = text(in: lookBehindRange) else {
                    assertionFailure()
                    return
                }
                
                lookBehindText.insert(contentsOf: prefix, at: firstTargetedNewLineIndex)
                
                let newSelectedText = selectedText.replacingOccurrences(of: "\n", with: "\n\(prefix)")
                let finalText = lookBehindText + newSelectedText
                if let finalRange = textRange(from: beginningOfDocument, to: selectedTextRange.end) {
                    replace(finalRange, withText: finalText)
                    
                    let newStart = position(
                        from: selectedTextRange.start,
                        offset: prefix.count
                    ) ?? beginningOfDocument
                    let newEnd = position(
                        from: selectedTextRange.end,
                        offset: (newSelectedText.count - selectedText.count) + prefix.count
                    ) ?? endOfDocument
                    self.selectedTextRange = textRange(from: newStart, to: newEnd)
                }
            }
        }
    }
    
    // MARK: Helper functions
    
    private func findLastNewlineIndex() -> String.Index? {
        if let start = selectedTextRange?.start, let lookBehindRange = textRange(from: beginningOfDocument, to: start),
           let lookBehindText = text(in: lookBehindRange) {
            if let newlineIndex = lookBehindText.lastIndex(of: "\n") {
                return lookBehindText.index(newlineIndex, offsetBy: 1, limitedBy: lookBehindText.endIndex)
            } else {
                return lookBehindText.startIndex
            }
        }
        return nil
    }

    private func stringIndex(from textPosition: UITextPosition) -> String.Index? {
        guard let text else { return nil }
        let offset = offset(from: beginningOfDocument, to: textPosition)
        guard offset >= 0, offset <= text.utf16.count else { return nil }
        return String.Index(utf16Offset: offset, in: text)
    }
}
