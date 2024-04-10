//
//  AppFlow.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-29.
//

enum AppFlow {
    case onboarding
    case guest(ApiClient)
    case user(UserStub)
}