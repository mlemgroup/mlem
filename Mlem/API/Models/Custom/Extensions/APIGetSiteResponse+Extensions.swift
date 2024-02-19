//
//  APIGetSiteResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APIGetSiteResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { site_view.site.actorId }
    var id: Int { site_view.site.id }
}
