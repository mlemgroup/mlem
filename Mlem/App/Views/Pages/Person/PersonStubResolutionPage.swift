//
//  PersonStubResolutionView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-08.
//

import MlemMiddleware
import SwiftUI

struct PersonStubResolutionPage: View {
    @Environment(NavigationLayer.self) var navigation
    
    let stub: PersonStub
    let visitContext: VisitHistory.VisitContext
    
    @State var upgradeError: Error?
    
    var body: some View {
        content
            .themedGroupedBackground()
    }
    
    @ViewBuilder
    var content: some View {
        if let upgradeError {
            ErrorView(.init(
                error: upgradeError,
                refresh: fetchPost
            ))
        } else {
            ProgressView()
                .task {
                    await fetchPost()
                }
        }
    }
    
    @discardableResult
    func fetchPost() async -> Bool {
        do {
            let person = try await stub.getPerson()
            navigation.replace(.person(person, visitContext: visitContext))
            return true
        } catch {
            upgradeError = error
            return false
        }
    }
}
