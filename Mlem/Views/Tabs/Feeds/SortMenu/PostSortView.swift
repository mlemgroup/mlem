//
//  PostSortMenu.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023
//

import SwiftUI
import Dependencies

struct PostSortView: View {
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    @Binding var isPresented: Bool
    @Binding var selected: PostSortType
    
    @State var presentationDetent: PresentationDetent
    var detents: Set<PresentationDetent>
    
    @Namespace var animation
    
    var body: some View {
        NavigationStack {
            ScrollView {
                content
            }
            // This is a super hacky fix that prevents the ScrollView from being refreshable. This behaviour seems to
            // be inherited from the FeedView for some reason.
            // https://stackoverflow.com/questions/72160368/how-to-disable-refreshable-in-nested-view-which-is-presented-as-sheet-fullscreen
            .environment((\EnvironmentValues.refresh as? WritableKeyPath<EnvironmentValues, RefreshAction?>)!, nil)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents(detents, selection: $presentationDetent)
        .presentationDragIndicator(.hidden)
    }

    var content: some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Sort by")
                PostSortPickerView(isPresented: $isPresented, selected: $selected)
                    .matchedGeometryEffect(id: "picker", in: animation)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("View mode")
                viewOptions
            }
            
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Filters")
                filterOptions
            }
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Settings")
                settingsOptions
            }
            Spacer()
                .frame(height: 70)
        }
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("View Options")
    }
    
    @ViewBuilder
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.leading, 10)
    }
    
    var viewOptions: some View {
        VStack(spacing: 0) {
            HStack {
                FormLabel(title: "Post Size", iconName: Icons.postSizeSetting)
                Spacer()
                Picker("Post Size", selection: $postSize) {
                    ForEach(PostSize.allCases, id: \.self) { type in
                        Text(type.label)
                    }
                }
                .tint(.secondary)
                .frame(width: 120)
            }
            .padding(.leading, 16)
            .padding(.vertical, 6)
            Divider()
            FormToggle(title: "Blur NSFW", iconName: "eye.trianglebadge.exclamationmark", isOn: $shouldBlurNsfw)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
        
    var filterOptions: some View {
        VStack(spacing: 0) {
            FormToggle(title: "Show Read Posts", iconName: "book", isOn: $showReadPosts)
            Divider()
            FormNavigationLink {
                FiltersSettingsView()
            } label: {
                FormLabel(title: "Keyword Filters", iconName: "character.textbox")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    var settingsOptions: some View {
        VStack(spacing: 0) {
            FormNavigationLink {
                PostSortDefaultPickerView()
            } label: {
                FormLabel(title: "Default Sort Mode", iconName: "text.line.first.and.arrowtriangle.forward")
            }
            Divider()
            FormNavigationLink {
                PostSortPinnedOptionsView()
            } label: {
                FormLabel(title: "Pinned Options", iconName: "pin")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}
