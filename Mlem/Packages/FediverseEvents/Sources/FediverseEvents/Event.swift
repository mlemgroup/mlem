//
//  Event.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import Foundation

public struct Event: Codable {
    public let id: String
    public let name: String
    public let start: Date
    public let end: Date
    public let endpoints: EventEndpoints
    public let logos: [EventLogo]
    public let social: [EventSocial]
}

public struct EventEndpoints: Codable {
    public let open: URL?
    public let auth_open: URL?
    public let more_info: URL?
}

public struct EventLogo: Codable {
    public let type: String // Mime type, e.g. "image/png"
    public let url: URL
    public let size: String // E.g. "512x512"
}

public struct EventSocial: Codable {
    public let icon: EventSocialIcon
    public let label: String
    public let url: URL
}

public enum EventSocialIcon: String, Codable {
    case mastodon, lemmy, matrix, discord, other
}
