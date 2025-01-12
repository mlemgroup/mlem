//
//  InstanceView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2024.
//

import MlemMiddleware
import SwiftUI

extension InstanceView {
    var tabs: [Tab] {
        var output: [Tab] = [.about, .administration, .details]
        if instance.canFetchUptime {
            output.append(.uptime)
        }
        output.append(.safety)
        return output
    }
    
    func logVisit(_ instance: any Instance3Providing) {
        guard let visitContext else { return }
        if let session = (appState.firstSession as? UserSession), let visitHistory = session.visitHistory {
            visitHistory.addInstance(instance.instance3.instanceSummary, context: visitContext)
            Task(priority: .background) {
                try await session.saveVisitHistory()
            }
        }
    }
    
    func openAddAdminSheet() {
        navigation.openSheet(.personPicker(filter: .local) { person in
            newAdmin = person
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingConfirmation = true
            }
        })
    }
    
    func addNewAdmin() {
        guard let newAdmin else {
            assertionFailure("newAdmin cannot be nil")
            return
        }
        guard newAdmin.apiIsLocal else {
            ToastModel.main.add(.error(.init(title: "Cannot appoint non-local user as administrator")))
            return
        }
        guard let instance3 = instance as? any Instance3Providing else {
            assertionFailure("Instance is not upgraded")
            return
        }
        guard instance.local || instance.host == "localhost" else {
            assertionFailure("Instance is not local")
            return
        }
        
        Task {
            do {
                try await instance3.addAdmin(personId: newAdmin.id, added: true)
            } catch {
                handleError(error)
            }
        }
    }
    
    func administratorQuickSwipes(person: any Person) -> SwipeConfiguration {
        guard let myPerson = appState.firstPerson,
              myPerson.api.isHigherAdmin(than: person),
              let myInstance = appState.firstApi.myInstance,
              let isAdmin = person.isAdmin_ else {
            return .none()
        }
        
        return .init(trailingActions: [person.addAdminAction(instance: myInstance, isOn: isAdmin)])
    }
    
    func attemptToLoadUptimeData() {
        print("Fetching uptime data...")
        if let url = instance.uptimeDataUrl {
            Task {
                do {
                    let data = try await URLSession.shared.data(from: url).0
                    let uptimeData = try JSONDecoder.defaultDecoder.decode(UptimeData.self, from: data)
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.uptimeData = .success(uptimeData)
                        }
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    func attemptToLoadFediseerData() {
        if fediseerData == nil, let host = instance.host {
            Task {
                do {
                    guard let instanceURL = URL(string: "https://fediseer.com/api/v1/whitelist/\(host)") else { return }
                    async let instanceData = try await URLSession.shared.data(from: instanceURL).0
                    
                    async let endorsementsData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/endorsements/\(host)")!
                    ).0
                    
                    async let hesitationsData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/hesitations/\(host)")!
                    ).0
                    
                    async let censuresData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/censures/\(host)")!
                    ).0
                    
                    let fediseerData = try await FediseerData(
                        instance: JSONDecoder.defaultDecoder.decode(
                            FediseerInstance.self,
                            from: instanceData
                        ),
                        endorsements: JSONDecoder.defaultDecoder.decode(
                            FediseerEndorsements.self,
                            from: endorsementsData
                        ).instances,
                        hesitations: JSONDecoder.defaultDecoder.decode(
                            FediseerHesitations.self,
                            from: hesitationsData
                        ).instances,
                        censures: JSONDecoder.defaultDecoder.decode(
                            FediseerCensures.self,
                            from: censuresData
                        ).instances
                    )
                    
                    Task { @MainActor in
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.fediseerData = fediseerData
                        }
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }
}
