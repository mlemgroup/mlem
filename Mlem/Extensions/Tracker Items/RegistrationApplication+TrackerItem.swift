//
//  RegistrationApplication+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Foundation

extension RegistrationApplicationModel: TrackerItem {
    var uid: ContentModelIdentifier { .init(contentType: .registrationApplication, contentId: application.id) }
    
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal {
        switch sortType {
        case .new: .new(application.published)
        case .old: .old(application.published)
        }
    }
}
