//
//  ParentTrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-17.
//
import Foundation

protocol ParentTrackerProtocol: AnyObject {
    associatedtype Item: TrackerItem
    
    func loadIfThreshold(_ item: Item)
    
    func refresh(clearBeforeFetch: Bool) async

    func reset() async
    
    func filter(with filter: @escaping (Item) -> Bool) async
    
    func changeSortType(to newSortType: TrackerSortVal.Case) async
}
