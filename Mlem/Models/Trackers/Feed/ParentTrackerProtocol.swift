//
//  ParentTrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-17.
//
import Foundation

protocol ParentTrackerProtocol: AnyObject {
    associatedtype Item: TrackerItem

    func shouldLoadContentAfter(_ item: Item) -> Bool

    func reload() async
    
    func refresh(clearBeforeFetch: Bool) async

    func reset() async
}
