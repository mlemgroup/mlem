//
//  Community3Providing.swift
//  Mlem
//
//  Created by Sam Marfleet on 12/02/2024.
//

import Foundation

protocol Community3Providing: Community2Providing {
    var community3: Community3 { get }
    
    var instance: Instance1! { get }
    var moderators: [Person1] { get }
    var discussionLanguages: [Int] { get }
    var defaultPostLanguage: Int? { get }
}

extension Community3Providing {
    var community2: Community2 { community3.community2 }
    
    var instance: Instance1! { community3.instance }
    var moderators: [Person1] { community3.moderators }
    var discussionLanguages: [Int] { community3.discussionLanguages }
    var defaultPostLanguage: Int? { community3.defaultPostLanguage }
    
    var instance_: Instance1? { community3.instance }
    var moderators_: [Person1]? { community3.moderators }
    var discussionLanguages_: [Int]? { community3.discussionLanguages }
    var defaultPostLanguage_: Int? { community3.defaultPostLanguage }
}
