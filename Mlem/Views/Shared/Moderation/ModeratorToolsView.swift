//
//  ModeratorToolsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-12.
//

import Foundation
import SwiftUI

// TOOLS TO ADD
//
// inline only
// - remove post (POST /post/remove)
// - lock post (POST /post/lock)
// - feature post (POST /post/feature)
// - distinguish comment (POST /comment/distinguish)
//
// inline and tools
// - ban user (POST /community/ban_user) (context menu, plus explicit user lookup tool)
//
// tools
// - edit community (PUT /community)
// - delete community (DELETE /community or POST /community/remove?)
// - moderators
//   - add mod (POST /community/mod)
//   - transfer community to another moderator (POST /community/transfer)
// - moderate user
//   - get report count (GET /user/report_count)
//   - get post history on your community (person details + filter)
//
// inbox
// - get post reports (GET /post/report/list)
// - resolve post report (PUT /post/report/resolve)
// - get comment reports (GET /comment/report/list)
// - resolve comment report (PUT /comment/report/resolve)
//
// investigate further
// - get banned users(?) (GET /user/banned)

struct ModeratorToolsView: View {
    @Environment(\.dismiss) var dismiss
    
    let community: CommunityModel
    
    var body: some View {
        content
            .navigationTitle("Moderating \(community.name)")
            .hoistNavigation()
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.bottom, AppConstants.standardSpacing)
                Divider()
                tools
                    .padding(.vertical, AppConstants.standardSpacing)
                    .background(Color(uiColor: .systemGroupedBackground))
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        AvatarBannerView(community: community)
            .padding(.top, AppConstants.standardSpacing)
        
        VStack(spacing: 5) {
            Text(community.displayName)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.01)
            Text(community.fullyQualifiedName ?? community.name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var tools: some View {
        Grid(horizontalSpacing: AppConstants.doubleSpacing, verticalSpacing: AppConstants.doubleSpacing) {
            GridRow {
                ToolButton(text: "Moderators", icon: Icons.moderationFill, color: .green)
                
                ToolButton(text: "Edit", icon: Icons.edit, color: .blue)
            }
            
            GridRow {
                ToolButton(text: "Audit User", icon: Icons.auditUser, color: .purple)
            }
        }
        .padding(.horizontal, AppConstants.doubleSpacing)
        .padding(.vertical, AppConstants.standardSpacing)
    }
}

struct ModeratorToolsViewPreview: PreviewProvider {
    static var previews: some View {
        ModeratorToolsView(community: .mock())
    }
}
