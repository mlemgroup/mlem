//
//  SelectableContentProviding.swift
//
//
//  Created by Sjmarf on 02/07/2024.
//

import Foundation

public protocol SelectableContentProviding: ActorIdentifiable {
    var selectableContent: String? { get }
}
