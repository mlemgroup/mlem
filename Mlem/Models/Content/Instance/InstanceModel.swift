//
//  InstanceModel.swift
//  Mlem
//
//  Created by Sjmarf on 13/01/2024.
//

import SwiftUI

struct InstanceModel {
    var instanceId: Int!
    var name: String!
    var description: String?
    var avatar: URL?
    var banner: URL?
    var administrators: [UserModel]?
    var url: URL!
    var version: SiteVersion?
    
    init(from response: SiteResponse) {
        self.update(with: response)
    }
    
    init(from site: APISite) {
        self.update(with: site)
    }
    
    mutating func update(with response: SiteResponse) {
        self.administrators = response.admins.map {
            var user = UserModel(from: $0)
            user.usesExternalData = true
            user.isAdmin = true
            return user
        }
        self.version = SiteVersion(response.version)
        self.update(with: response.siteView.site)
    }
    
    mutating func update(with site: APISite) {
        instanceId = site.id
        name = site.name
        description = site.sidebar
        avatar = site.iconUrl
        banner = site.bannerUrl
        
        if var components = URLComponents(string: site.inboxUrl) {
            components.path = ""
            url = components.url
        }
    }
}

extension InstanceModel: Identifiable {
    var id: Int { hashValue }
}

extension InstanceModel: Hashable {
    static func == (lhs: InstanceModel, rhs: InstanceModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(instanceId)
    }
}
