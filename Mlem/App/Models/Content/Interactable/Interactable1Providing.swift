//
//  Interactable1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

/// Represents a post/comment that you *should* be able to interact with, but you cannot actually interact with due to the model being too low-tier.
protocol Interactable1Providing: AnyObject, Actionable, ContentStub {
    var creationDate: Date { get }
    var updatedDate: Date? { get }
}
