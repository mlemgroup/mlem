//
//  APILocalSite+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension APILocalSite {
    static func mock(
        enableDownvotes: Bool = true,
        enableNsfw: Bool = true,
        communityCreationAdminOnly: Bool = false,
        requireEmailVerification: Bool = false,
        privateInstance: Bool = false,
        defaultPostListingType: APIListingType = .local,
        hideModlogModNames: Bool = false,
        applicationEmailAdmins: Bool = false,
        slurFilterRegex: String? = nil,
        federationEnabled: Bool = true,
        federationSignedFetch: Bool = false,
        captchaEnabled: Bool = true,
        captchaDifficulty: APICaptchaDifficulty = .medium,
        registrationMode: APIRegistrationMode = .open,
        reportsEmailAdmins: Bool = false,
        published: Date = .mock
    ) -> APILocalSite {
        .init(
            enableDownvotes: enableDownvotes,
            enableNsfw: enableNsfw,
            communityCreationAdminOnly: communityCreationAdminOnly,
            requireEmailVerification: requireEmailVerification,
            privateInstance: privateInstance,
            defaultPostListingType: defaultPostListingType,
            hideModlogModNames: hideModlogModNames,
            applicationEmailAdmins: applicationEmailAdmins,
            slurFilterRegex: slurFilterRegex,
            federationEnabled: federationEnabled,
            federationSignedFetch: federationSignedFetch,
            captchaEnabled: captchaEnabled,
            captchaDifficulty: captchaDifficulty,
            registrationMode: registrationMode,
            reportsEmailAdmins: reportsEmailAdmins,
            published: published
        )
    }
}
