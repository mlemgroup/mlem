//
//  InstanceTier1.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Foundation
import Observation
import SwiftUI

enum PermissionError: Error {
    case notLoggedIn, notAModerator, notAnAdministrator
}

protocol Instance1Providing: InstanceStubProviding {
    var displayName: String { get }
    var description: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var creationDate: Date { get }
    var publicKey: String { get }
}

@Observable
final class Instance1: Instance1Providing, CoreModel {
    static var cache: CoreContentCache<Instance1> = .init()
    
    var url: URL

    typealias APIType = APISite
    
    let stub: NewInstanceStub
    
    var actorId: URL { stub.actorId }

    let creationDate: Date
    let publicKey: String

    var displayName: String = ""
    var description: String? = nil
    var avatar: URL? = nil
    var banner: URL? = nil

    required init(from site: APISite) {
        self.creationDate = site.published
        self.publicKey = site.publicKey
        self.stub = .create(url: site.actorId)
        self.update(with: site)
    }

    func update(with site: APISite) {
        self.displayName = site.name
        self.description = site.sidebar
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
    }
}
