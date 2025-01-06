//
//  VisitHistory.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-01.
//

import Foundation
import MlemMiddleware

@Observable
class VisitHistory {
    enum VisitContext: Codable {
        case search, other
        
        var maximumHistorySize: Int {
            switch self {
            case .search: 15
            case .other: 5
            }
        }
    }
    
    struct VisitRecord<T> {
        let value: T
        let date: Date
    }
    
    private(set) var communityRecords: [VisitContext: [VisitRecord<Community2>]]
    private(set) var personRecords: [VisitContext: [VisitRecord<Person2>]]
    
    // Using `InstanceSummary` here rather than an `Instance` model because otherwise we'd need
    // to store full `Instance3` models in order to have access to the site `version`, which means
    // storing a lot of other unnecessary data.
    private(set) var instanceRecords: [VisitContext: [VisitRecord<InstanceSummary>]]
    
    init(
        communityRecords: [VisitContext: [VisitRecord<Community2>]] = [:],
        personRecords: [VisitContext: [VisitRecord<Person2>]] = [:],
        instanceRecords: [VisitContext: [VisitRecord<InstanceSummary>]] = [:]
    ) {
        self.communityRecords = communityRecords
        self.personRecords = personRecords
        self.instanceRecords = instanceRecords
    }
    
    var isEmpty: Bool {
        communityRecords.isEmpty && personRecords.isEmpty && instanceRecords.isEmpty
    }
    
    func communities(withContext context: VisitContext) -> [Community2] {
        communityRecords[context]?.map(\.value) ?? []
    }
    
    func communities(withContexts contexts: Set<VisitContext>) -> [Community2] {
        contexts
            .reduce(into: []) { result, context in
                result += communityRecords[context] ?? []
            }
            .sorted { $0.date > $1.date }
            .map(\.value)
            .uniqued()
    }
    
    func people(withContext context: VisitContext) -> [Person2] {
        personRecords[context]?.map(\.value) ?? []
    }
    
    func instances(withContext context: VisitContext) -> [InstanceSummary] {
        instanceRecords[context]?.map(\.value) ?? []
    }
    
    @MainActor
    func addCommunity(_ community: Community2, context: VisitContext) {
        addValue(community, to: &communityRecords, context: context)
    }
    
    @MainActor
    func addPerson(_ person: Person2, context: VisitContext) {
        addValue(person, to: &personRecords, context: context)
    }
    
    @MainActor
    func addInstance(_ instance: InstanceSummary, context: VisitContext) {
        addValue(instance, to: &instanceRecords, context: context)
    }
    
    private func addValue<T: Equatable>(
        _ value: T,
        to dict: inout [VisitContext: [VisitRecord<T>]],
        context: VisitContext
    ) {
        if let index = dict[context, default: []].firstIndex(where: { $0.value == value }) {
            dict[context, default: []].remove(at: index)
        }
        
        if !dict.keys.contains(context) {
            dict[context] = []
        }
        dict[context]?.prepend(.init(value: value, date: .now))
        
        if dict[context, default: []].count > context.maximumHistorySize {
            dict[context, default: []].removeLast()
        }
    }
    
    func clear() {
        communityRecords = [:]
    }
}

extension Set<VisitHistory.VisitContext> {
    static var all: Set<VisitHistory.VisitContext> {
        [.other, .search]
    }
}
