//
//  PersonListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct PersonListRow<Content2: View>: View {
    typealias Content = PersonListRowBody<Content2>
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.communityContext) var communityContext
    @Setting(\.interactionBar_person) var personActionConfiguration
    
    let person: Person
    let content: Content
    let visitContext: VisitHistory.VisitContext

    init(
        _ person: Person,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        visitContext: VisitHistory.VisitContext = .other,
        @ViewBuilder content: @escaping () -> Content2
    ) {
        self.person = person
        self.content = .init(person, complications: complications, showBlockStatus: showBlockStatus, content: content)
        self.visitContext = visitContext
    }
    
    init(
        _ person: Person,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil,
        visitContext: VisitHistory.VisitContext = .other
    ) where Content2 == EmptyView {
        self.person = person
        self.content = .init(person, complications: complications, showBlockStatus: showBlockStatus, readout: readout)
        self.visitContext = visitContext
    }
    
    var body: some View {
        Button {
            navigation.push(.person(person, visitContext: visitContext))
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu(person: person)
        .quickSwipes(person: person, configuration: personActionConfiguration, leadingBuffer: .standard)
        .popupAnchor()
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment) {
//        ScrollView {
//            ForEach(PersonMockType.Realistic.allCases) { type in
//                PersonListRow(
//                    Person2.mock(.realistic(type)),
//                    complications: [.instance, .date],
//                    readout: .postsAndComments
//                )
//            }
//        }
//        .contentMargins(.horizontal, Constants.main.standardSpacing)
//        .background(.themedGroupedBackground)
//    }
// #endif
