//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2026-06-16.
//  

import Foundation
import LemmyMarkdownUI

public class LazyMarkdown {
    private var string_: String
    private var markdown_: [BlockNode]?
    public var translatedMarkdown: [BlockNode]?

    init(_ string: String) {
        self.string_ = string
    }

    public var string: String {
        get { string_ }
        set {
            self.string_ = newValue
            self.markdown_ = nil
            self.translatedMarkdown = nil
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

