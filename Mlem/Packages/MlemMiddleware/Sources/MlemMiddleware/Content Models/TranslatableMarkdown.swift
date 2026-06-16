//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2026-06-16.
//  

import Foundation
import LemmyMarkdownUI
import Observation

@Observable
public class TranslatableMarkdown {
    public enum TranslationState: Hashable {
        case untranslated
        case translating
        case translated([BlockNode])
    }

    private var string_: String
    private var markdown_: [BlockNode]?
    public var translated: TranslationState = .untranslated

    init(_ string: String) {
        self.string_ = string
    }

    public var string: String {
        get { string_ }
        set {
            self.string_ = newValue
            self.markdown_ = nil
            self.translated = .untranslated
        }
    }

    public var markdown: [BlockNode] {
        get {
            if let markdown_ {
                return markdown_
            } else {
                let blocks: [BlockNode] = .init(string_)
                self.markdown_ = blocks
                return blocks
            }
        }
    }
}

