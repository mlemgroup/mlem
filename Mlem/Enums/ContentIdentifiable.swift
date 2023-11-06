//
//  ContentIdentifiable.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//
import Foundation

// TODO: migrate this to be ContentModel and make subtypes of ContentModel for content with URLs, etc.
protocol ContentIdentifiable {
    var uid: ContentModelIdentifier { get }
}
