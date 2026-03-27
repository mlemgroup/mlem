//
//  File.swift
//  MlemBackend
//
//  Created by Sjmarf on 2026-03-18.
//  

import Foundation

public struct InstanceSummarySoftware: Codable, Hashable {
    public let type: InstanceSummarySoftwareType
    public let version: String
    
    public init(type: InstanceSummarySoftwareType, version: String) {
        self.type = type
        self.version = version
    }
}

public enum InstanceSummarySoftwareType: String, Codable, Hashable {
    case lemmy, pieFed
}
