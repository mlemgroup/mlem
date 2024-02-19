//
//  APIGetSiteResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APIGetSiteResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { siteView.site.actorId }
    var id: Int { siteView.site.id }
}
