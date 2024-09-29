//
//  InstanceStubProviding+Uptime.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2024.
//

import Foundation
import MlemMiddleware

private let uptimeSupportedInstances: Set<String> = [
    "aussie.zone",
    "beehaw.org",
    "discuss.online",
    "discuss.tchncs.de",
    "dubvee.org",
    "feddit.org",
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
    "startrek.website",
    "szmer.info",
    "toast.ooo"
]

extension InstanceStubProviding {
    var canFetchUptime: Bool {
        if let host {
            return uptimeSupportedInstances.contains(host)
        }
        return false
    }

    var uptimeDataUrl: URL? {
        guard canFetchUptime, let host else { return nil }
        let name = "_\(host.replacingOccurrences(of: ".", with: "-"))"
        return URL(string: "https://lemmy-status.org/api/v1/endpoints/\(name)/statuses?page=1")
    }
    
    var uptimeFrontendUrl: URL? {
        guard canFetchUptime, let host else { return nil }
        let name = "_\(host.replacingOccurrences(of: ".", with: "-"))"
        return URL(string: "https://lemmy-status.org/endpoints/\(name)")
    }
}
