//
//  VisitHistory+CodedData.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-01.
//

import Foundation
import MlemMiddleware

extension VisitHistory {
    struct CodedData: Codable {
        var communities: [VisitContext: [CodedVisitRecord<Community2.CodedData>]] = [:]
        var people: [VisitContext: [CodedVisitRecord<Person2.CodedData>]] = [:]
        var instances: [VisitContext: [CodedVisitRecord<InstanceSummary>]] = [:]
    }
    
    struct CodedVisitRecord<T: Codable>: Codable {
        let value: T
        let date: Date
    }
    
    convenience init(data: CodedData, api: ApiClient) async throws {
        let communityRecords = try await data.communities.mapValueArraysAsync { item in
            try await VisitRecord<Community2>(value: api.decodeCommunity(item.value), date: item.date)
        }
        let personRecords = try await data.people.mapValueArraysAsync { item in
            try await VisitRecord<Person2>(value: api.decodePerson(item.value), date: item.date)
        }
        self.init(
            communityRecords: communityRecords,
            personRecords: personRecords,
            instanceRecords: data.instances.mapValues {
                $0.map { .init(value: $0.value, date: $0.date) }
            }
        )
    }
    
    func codedData() async throws -> CodedData {
        let communities = try await communityRecords.mapValueArraysAsync { item in
            try await CodedVisitRecord<Community2.CodedData>(value: item.value.codedData(), date: item.date)
        }
        
        let people = try await personRecords.mapValueArraysAsync { item in
            try await CodedVisitRecord<Person2.CodedData>(value: item.value.codedData(), date: item.date)
        }
        return .init(
            communities: communities,
            people: people,
            instances: instanceRecords.mapValues {
                $0.map { .init(value: $0.value, date: $0.date) }
            }
        )
    }
}

private func decodeDictionary<InputValue, OutputValue>(
    _ input: [VisitHistory.VisitContext: [InputValue]],
    _ transform: (InputValue) async throws -> OutputValue
) async throws -> [VisitHistory.VisitContext: [OutputValue]] {
    var output: [VisitHistory.VisitContext: [OutputValue]] = [:]
    for (context, items) in input {
        var outputValues: [OutputValue] = []
        for item in items {
            try await outputValues.append(transform(item))
        }
        output[context] = outputValues
    }
    return output
}

private extension Dictionary where Value: Collection, Key == VisitHistory.VisitContext {
    func mapValueArraysAsync<OutputValue>(
        _ transform: (Value.Element) async throws -> OutputValue
    ) async throws -> [Key: [OutputValue]] {
        var output: [Key: [OutputValue]] = [:]
        for (context, items) in self {
            var outputValues: [OutputValue] = []
            for item in items {
                try await outputValues.append(transform(item))
            }
            output[context] = outputValues
        }
        return output
    }
}
