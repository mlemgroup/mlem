//
//  [BlockNode]+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2024.
//

import LemmyMarkdownUI

extension [BlockNode] {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func rules() -> [[BlockNode]] {
        var output: [[BlockNode]] = []
        
        /// Is `true` when the previous block was a "Rules" title, or if there is only one block in the array.
        var isProbableRuleList: Bool = self.count == 1
       
        /// Stores the parts of a rule currently being parsed.
        var currentRuleParts: [BlockNode]?
        
        // Matches "1. ", "2) ", "Rule 1" etc
        let numberedListRegex = /\d+[-\.:\)]\s+|Rule \d+[-\.:\)]?\s+/
        
        loop: for block in self {
            if let parts = currentRuleParts {
                switch block {
                case .heading:
                    output.append(parts)
                    currentRuleParts = nil
                case .thematicBreak:
                    if parts.count > 1 {
                        output.append(parts)
                        currentRuleParts = nil
                    } else {
                        fallthrough
                    }
                default:
                    currentRuleParts?.append(block)
                    continue loop
                }
            }
            
            switch block {
            case let .paragraph(inlines: inlines), .heading(level: _, inlines: let inlines):
                // Test if the heading is a rule title e.g. "1. No spam"
                if inlines.stringLiteral.starts(with: numberedListRegex) {
                    // This doesn't preserve the markdown in the title, but it's a rare case for there to be any
                    let text = String(inlines.stringLiteral.trimmingPrefix(numberedListRegex))
                    
                    let blocks: [BlockNode] = [.paragraph(inlines: [.strong(children: [.text(text)])])]
                    if case .paragraph = block {
                        output.append(blocks)
                    } else {
                        currentRuleParts = blocks
                    }
                    break
                }
                
                // AskLemmy uses "criteria" rather than "rules"
                // TODO: localize this?
                if ["Rules", "Criteria"].contains(where: { inlines.stringLiteral.localizedCaseInsensitiveContains($0) }) {
                    isProbableRuleList = true
                    continue loop
                }
            case .bulletedList(isTight: _, items: let items, truncatedRows: _),
                 .numberedList(isTight: _, start: _, items: let items, truncatedRows: _):
                if isProbableRuleList {
                    output.append(contentsOf: items.map(\.blocks))
                }
                isProbableRuleList = false
            case let .spoiler(title: title, blocks: blocks):
                if let title, title.starts(with: numberedListRegex) {
                    let text = String(title.trimmingPrefix(numberedListRegex))
                    let titleBlock: BlockNode = .paragraph(
                        inlines: [
                            .strong(children: [.text(text)])
                        ]
                    )
                    output.append([titleBlock] + blocks.filter { $0 != .thematicBreak })
                }
            default:
                break
            }
        }
        
        if let currentRuleParts {
            output.append(currentRuleParts)
        }
        
        return output
    }
}
