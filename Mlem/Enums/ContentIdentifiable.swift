//
//  ContentIdentifiable.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//
import Foundation

// TODO: this feels like it should be the proper ContentModel protocol, since it's the most generic content model--maybe we can have an ImageContentModel type that extends this?
protocol ContentIdentifiable {
    var uid: ContentModelIdentifier { get }
}
