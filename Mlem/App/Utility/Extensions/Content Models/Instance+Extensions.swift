//
//  Instance3+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-02.
//

import Foundation
import MlemMiddleware
import MlemBackend

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

extension Instance {
    func slurRegex() -> Regex<AnyRegexOutput>? {
        do {
            if let regex = slurFilterRegex.value as? String {
                return try .init(regex)
            }
        } catch {
            handleError(error, silent: true)
        }
        return nil
    }
    
    var instanceSummary: InstanceSummary? {
        if let userCount = userCount.value,
           let software = software.value {
            return .init(
                displayName: displayName,
                name: name,
                totalUsers: userCount,
                avatar: avatar,
                software: .init(from: software)
            )
        }
        return nil
    }
    
    var canFetchUptime: Bool { uptimeSupportedInstances.contains(host) }
    
    var uptimeDataUrl: URL? {
        guard canFetchUptime else { return nil }
        let name = "_\(host.replacingOccurrences(of: ".", with: "-"))"
        return URL(string: "https://lemmy-status.org/api/v1/endpoints/\(name)/statuses?page=1")
    }
    
    var uptimeFrontendUrl: URL? {
        guard canFetchUptime else { return nil }
        let name = "_\(host.replacingOccurrences(of: ".", with: "-"))"
        return URL(string: "https://lemmy-status.org/endpoints/\(name)")
    }
}
