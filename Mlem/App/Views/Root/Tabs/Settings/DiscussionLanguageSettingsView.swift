//
//  DiscussionLanguageSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-06.
//

import SwiftUI
import MlemMiddleware

struct DiscussionLanguageSettingsView: View {
    @Environment(Palette.self) var palette
    
    @State var instance: (any Instance3Providing)?
    @State var person: (any Person4Providing)?
    
    @State var submitting: Int?
    
    init() {
        if let firstInstance = AppState.main.firstApi.myInstance {
            self._instance = .init(wrappedValue: firstInstance)
        }
        if let firstPerson = AppState.main.firstPerson {
            self._person = .init(wrappedValue: firstPerson)
        }
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Discussion Languages",
                // swiftlint:disable:next line_length
                description: "Choose which languages appear in your feed. Posts and comments written in other languages will be hidden.",
                systemImage: Icons.language)
            
            if let languages = person?.discussionLanguages, !languages.contains(0) {
                Section {
                    Label("You will not see most content if Undetermined is not selected.", systemImage: Icons.warningFill)
                        .foregroundStyle(palette.warning)
                }
            }
            
            Section {
                if let instance, let person {
                    ForEach(instance.allLanguages, id: \.id) { language in
                        Button {
                            if submitting == nil {
                                submitting = language.id
                                Task {
                                    await updateDiscussionLanguages(with: language.id)
                                }
                            }
                        } label: {
                            HStack {
                                Text(language.name)
                                
                                Spacer()
                                
                                if submitting == language.id {
                                    ProgressView()
                                } else if person.discussionLanguages.contains(language.id) {
                                    Image(systemName: Icons.success)
                                        .foregroundStyle(palette.accent)
                                }
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    ProgressView()
                        .task {
                            do {
                                try await (person, instance, _) = AppState.main.firstApi.getMyPerson()
                            } catch {
                                handleError(error)
                            }
                        }
                }
            }
        }
        .contentMargins(.top, 16)
    }
    
    func updateDiscussionLanguages(with id: Int) async {
        defer { submitting = nil }
        
        guard let person else {
            assertionFailure("No person found")
            return
        }
        
        var newLangs = person.discussionLanguages
        if newLangs.contains(id) {
            newLangs.remove(id)
        } else {
            newLangs.insert(id)
        }
        do {
            try await person.person4.updateSettings(discussionLanguages: newLangs)
        } catch {
            handleError(error)
        }
    }
}
