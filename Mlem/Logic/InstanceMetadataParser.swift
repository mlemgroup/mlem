//
//  InstanceMetadataParser.swift
//  Mlem
//
//  Created by mormaer on 31/08/2023.
//
//

import Foundation

/// A parser for the metadata received from `awesome-lemmy-instances`
struct InstanceMetadataParser {
    enum ParsingError: Error {
        case invalidData
        case requiredHeaderMissing
        case requestedIndexNotPresent
        case noInstancesFound
    }
    
    private enum Field: String, CaseIterable {
        case instance = "Instance"
        case newCommunities = "NC"
        case newUsers = "NU"
        case federated = "Fed"
        case adultContent = "Adult"
        case downvotes = "↓V"
        case users = "Users"
        case blockingInstanceCount = "BI"
        case blockedByCount = "BB"
        case uptime = "UT"
        case version = "Version"
    }
    
    private struct IndexContainer {
        private var dictionary = [Field: Int]()
        
        var count: Int { dictionary.count }
        
        mutating func add(_ field: Field, for index: Int) {
            dictionary[field] = index
        }
        
        func index(of field: Field) throws -> Int {
            guard let index = dictionary[field] else {
                throw ParsingError.requestedIndexNotPresent
            }
            
            return index
        }
    }
    
    // MARK: - Initialisation
    
    private init() { /* This struct is not designed to be constructed, use it's static method `.parse(from: ...)` */ }
    
    // MARK: - Public Methods
    
    static func parse(from data: Data) throws -> [InstanceMetadata] {
        guard let string = String(data: data, encoding: .utf8), !string.isEmpty else {
            throw ParsingError.invalidData
        }
        
        var lines = string.split(separator: "\n")
        let headerFields = lines.removeFirst().split(separator: ",").map { String($0) }
        let indexes = createIndexContainer(from: headerFields)
        
        guard indexes.count == Field.allCases.count else {
            throw ParsingError.requiredHeaderMissing
        }
        
        let metadata = lines.compactMap { try? parseLine($0, using: indexes) }
        
        guard !metadata.isEmpty else {
            throw ParsingError.noInstancesFound
        }
        
        return metadata
    }
    
    // MARK: - Private Methods
    
    private static func createIndexContainer(from headerFields: [String]) -> IndexContainer {
        headerFields.reduce(into: IndexContainer()) { container, identifier in
            guard
                let field = Field(rawValue: identifier),
                let index = index(of: field, in: headerFields)
            else {
                return
            }
            
            container.add(field, for: index)
        }
    }
    
    private static func index(of field: Field, in fields: [String]) -> Int? {
        guard let index = fields.firstIndex(of: field.rawValue) else {
            return nil
        }
        
        return Int(index)
    }
    
    private static func parseLine(_ line: Substring, using indexes: IndexContainer) throws -> InstanceMetadata? {
        let fields = line.split(separator: ",").map { String($0) }
        
        // matches [instance name](instance url)
        let regex = /\[(?'name'.*)\]\((?'url'.*)\)/
        guard
            let urlMatch = try fields[indexes.index(of: .instance)].firstMatch(of: regex),
            let url = URL(string: String(urlMatch.output.url))
        else {
            return nil
        }
        
        let name = String(urlMatch.output.name)
        let newUsers = try fields[indexes.index(of: .newUsers)] == "Yes"
        let newCommunities = try fields[indexes.index(of: .newCommunities)] == "Yes"
        let federated = try fields[indexes.index(of: .federated)] == "Yes"
        let adult = try fields[indexes.index(of: .adultContent)] == "Yes"
        let downvotes = try fields[indexes.index(of: .downvotes)] == "Yes"
        guard let users = try Int(fields[indexes.index(of: .users)]) else { return nil }
        guard let blocking = try Int(fields[indexes.index(of: .blockingInstanceCount)]) else { return nil }
        guard let blockedBy = try Int(fields[indexes.index(of: .blockedByCount)]) else { return nil }
        let uptime = try String(fields[indexes.index(of: .uptime)])
        let version = try String(fields[indexes.index(of: .version)])
        
        return InstanceMetadata(
            name: name,
            url: url,
            newUsers: newUsers,
            newCommunities: newCommunities,
            federated: federated,
            adult: adult,
            downvotes: downvotes,
            users: users,
            blocking: blocking,
            blockedBy: blockedBy,
            uptime: uptime,
            version: version
        )
    }
}
