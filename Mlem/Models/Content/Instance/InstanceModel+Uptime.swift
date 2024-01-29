//
//  InstanceModel+Uptime.swift
//  Mlem
//
//  Created by Sjmarf on 28/01/2024.
//

import SwiftUI

extension InstanceModel {
    
    // Instances watched by lemmy-status.org
    static let uptimeSupportedInstances: [String] = [
        "aussie.zone",
        "beehaw.org",
        "discuss.online",
        "discuss.tchncs.de",
        "dubvee.org",
        "feddit.de",
        "feddit.dk",
        "hexbear.net",
        "infosec.pub",
        "jlai.lu",
        "lemdro.id",
        "lemm.ee",
        "lemmings.world",
        "lemmy.blahaj.zone",
        "lemmy.ca",
        "lemmy.dbzer0.com",
        "lemmy.eco.br",
        "lemmy.ml",
        "lemmy.myserv.one",
        "lemmy.nz",
        "lemmy.world",
        "lemmy.zip",
        "literature.cafe",
        "mander.xyz",
        "midwest.social",
        "programming.dev",
        "sh.itjust.works",
        "slrpnk.net",
        "sopuli.xyz",
        "startrek.website"
    ]
    
    var canFetchUptime: Bool { InstanceModel.uptimeSupportedInstances.contains(name) }

    var uptimeDataUrl: URL? {
        guard canFetchUptime else { return nil }
        let name = "_\(name.replacingOccurrences(of: ".", with: "-"))"
        return URL(string: "https://lemmy-status.org/api/v1/endpoints/\(name)/statuses?page=1")
    }
    
    var uptimeFrontendUrl: URL? {
        guard canFetchUptime else { return nil }
        let name = "_\(name.replacingOccurrences(of: ".", with: "-"))"
        return URL(string: "https://lemmy-status.org/endpoints/\(name)")
    }
}
