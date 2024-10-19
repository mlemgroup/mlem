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
        var isProbableRuleList: Bool = count == 1
       
        /// Stores the parts of a rule currently being parsed.
        /// This happens when a rule consists of a heading followed by a paragraph.
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
                if stringIsRulesTitle(inlines.stringLiteral) {
                    isProbableRuleList = true
                    continue loop
                }
            case .bulletedList(isTight: _, items: let items),
                 .numberedList(isTight: _, start: _, items: let items):
                if isProbableRuleList {
                    output.append(contentsOf: items.map(\.blocks))
                }
                isProbableRuleList = false
            case let .spoiler(title: title, blocks: blocks):
                // This handles the situation where a spoiler is used to enclose the rules list.
                if let title, stringIsRulesTitle(title) {
                    return blocks.rules()
                }
                // This handles situations where each item of the rules list contains a spoiler
                // block that can be expanded for more info on that rule.
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

private func stringIsRulesTitle(_ string: String) -> Bool {
    ["Rules", "Criteria"].contains(where: { string.localizedCaseInsensitiveContains($0) })
}
