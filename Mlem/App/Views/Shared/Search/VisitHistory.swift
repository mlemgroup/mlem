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
    
    private(set) var communityRecords: [VisitContext: [VisitRecord<Community>]]
    private(set) var personRecords: [VisitContext: [VisitRecord<Person>]]
    
    // Using `InstanceSummary` here rather than an `Instance` model because otherwise we'd need
    // to store full `Instance3` models in order to have access to the site `version`, which means
    // storing a lot of other unnecessary data.
    private(set) var instanceRecords: [VisitContext: [VisitRecord<InstanceSummary>]]
    
    init(
        communityRecords: [VisitContext: [VisitRecord<Community>]] = [:],
        personRecords: [VisitContext: [VisitRecord<Person>]] = [:],
        instanceRecords: [VisitContext: [VisitRecord<InstanceSummary>]] = [:]
    ) {
        self.communityRecords = communityRecords
        self.personRecords = personRecords
        self.instanceRecords = instanceRecords
    }
    
    var isEmpty: Bool {
        communityRecords.isEmpty && personRecords.isEmpty && instanceRecords.isEmpty
    }
    
    func communities(withContext context: VisitContext) -> [Community] {
        communityRecords[context]?.map(\.value) ?? []
    }
    
    func communities(withContexts contexts: Set<VisitContext>) -> [Community] {
        contexts
            .reduce(into: []) { result, context in
                result += communityRecords[context] ?? []
            }
            .sorted { $0.date > $1.date }
            .map(\.value)
            .uniqued()
    }
    
    func people(withContext context: VisitContext) -> [Person] {
        personRecords[context]?.map(\.value) ?? []
    }
    
    func instances(withContext context: VisitContext) -> [InstanceSummary] {
        instanceRecords[context]?.map(\.value) ?? []
    }
    
    @MainActor
    func addCommunity(_ community: Community, context: VisitContext) {
        addValue(community, to: &communityRecords, context: context)
    }
    
    @MainActor
    func removeCommunity(_ community: Community, context: VisitContext) {
        removeValue(community, from: &communityRecords, context: context)
    }
    
    @MainActor
    func addPerson(_ person: Person, context: VisitContext) {
        addValue(person, to: &personRecords, context: context)
    }
    
    @MainActor
    func removePerson(_ person: Person, context: VisitContext) {
        removeValue(person, from: &personRecords, context: context)
    }
    
    @MainActor
    func addInstance(_ instance: InstanceSummary, context: VisitContext) {
        addValue(instance, to: &instanceRecords, context: context)
    }
    
    @MainActor
    func removeInstance(_ instance: InstanceSummary, context: VisitContext) {
        removeValue(instance, from: &instanceRecords, context: context)
    }
    
    private func addValue<T: Equatable>(
        _ value: T,
        to dict: inout [VisitContext: [VisitRecord<T>]],
        context: VisitContext
    ) {
        removeValue(value, from: &dict, context: context)
        
        if !dict.keys.contains(context) {
            dict[context] = []
        }
        dict[context]?.prepend(.init(value: value, date: .now))
        
        if dict[context, default: []].count > context.maximumHistorySize {
            dict[context, default: []].removeLast()
        }
    }
    
    private func removeValue<T: Equatable>(
        _ value: T,
        from dict: inout [VisitContext: [VisitRecord<T>]],
        context: VisitContext
    ) {
        if let index = dict[context, default: []].firstIndex(where: { $0.value == value }) {
            dict[context, default: []].remove(at: index)
        }
    }
    
    func clear() {
        communityRecords = [:]
        personRecords = [:]
        instanceRecords = [:]
    }
}

extension Set<VisitHistory.VisitContext> {
    static var all: Set<VisitHistory.VisitContext> {
        [.other, .search]
    }
}
