//
//  PostSortMenu.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023
//

import SwiftUI
import Dependencies

struct PostSortView: View {
    @Binding var isPresented: Bool
    @Binding var selected: PostSortType
    @Binding var showReadPosts: Bool
    
    @State var presentationDetent: PresentationDetent
    var detents: Set<PresentationDetent>
    
    @Namespace var animation
    
    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
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
        GeometryReader { geometry in
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sort by")
                        .font(.headline)
                        .padding(.leading, 10)
                        .opacity(min(max((geometry.size.height - 400) * 0.01, 0), 1))
                        .frame(height: 30 * min(max((geometry.size.height - 300) * 0.01, 0), 1))
                    PostSortPickerView(isPresented: $isPresented, selected: $selected)
                        .matchedGeometryEffect(id: "picker", in: animation)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Filters")
                        .font(.headline)
                        .padding(.leading, 10)
                    excludeOptions
                }
                .opacity(min(max((geometry.size.height - 400) * 0.01, 0), 1))
                .scaleEffect(min(max(0.9 + (geometry.size.height - 400) * 0.001, 0.9), 1))
                Spacer()
            }
            .padding(.horizontal, 16)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Sort & Filter")
        }
    }
    
    var excludeOptions: some View {
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
}

 private struct FormToggle: View {
    let title: String
    let iconName: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            FormLabel(title: title, iconName: iconName)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
 }

private struct FormLabel: View {
    let title: String
    let iconName: String
    
    var body: some View {
        Label {
            Text(title)
                .padding(.vertical, 8)
        } icon: {
            Image(systemName: iconName)
                .imageScale(.large)
                .foregroundStyle(.blue)
                .frame(width: 30)
                .padding(.trailing, 5)
        }
    }
}

private struct FormNavigationLink<Destination: View, Label: View>: View {
    
    let destination: Destination
    let label: Label
    
    init(@ViewBuilder _ destination: () -> Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination()
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                label
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .imageScale(.small)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}
