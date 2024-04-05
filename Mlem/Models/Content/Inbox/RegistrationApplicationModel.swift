//
//  RegistrationApplicationModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Dependencies
import Foundation

class RegistrationApplicationModel: ObservableObject {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.apiClient) var apiClient
    
    @Published var application: APIRegistrationApplication
    @Published var creator: UserModel
    @Published var resolver: UserModel?
    
    init(application: APIRegistrationApplication, creator: UserModel, resolver: UserModel? = nil) {
        self.application = application
        self.creator = creator
        self.resolver = resolver
    }
    
    @MainActor
    func reinit(from application: RegistrationApplicationModel) {
        self.application = application.application
        creator = application.creator
        resolver = application.resolver
    }
    
    // TODO:
    func approve() async {
        do {
            let response = try await apiClient.approveRegistrationApplication(
                applicationId: application.id,
                approve: true,
                denyReason: nil
            )
            await reinit(from: response)
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func deny(reason: String) async -> Bool {
        do {
            let response = try await apiClient.approveRegistrationApplication(
                applicationId: application.id,
                approve: false,
                denyReason: reason
            )
            await reinit(from: response)
            return true
        } catch {
            errorHandler.handle(error)
        }
        return false
    }
}

extension RegistrationApplicationModel: Hashable, Equatable {
    static func == (lhs: RegistrationApplicationModel, rhs: RegistrationApplicationModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(application)
        hasher.combine(creator)
        hasher.combine(resolver)
    }
}
