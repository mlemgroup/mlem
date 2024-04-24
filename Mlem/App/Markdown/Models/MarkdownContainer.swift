//
//  MarkdownContainer.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation

protocol MarkdownContainer {
    var children: [any MarkdownContainer] { get }
}
