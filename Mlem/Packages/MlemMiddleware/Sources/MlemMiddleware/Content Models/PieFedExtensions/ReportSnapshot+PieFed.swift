//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-25.
//

import Foundation

extension ReportSnapshot {
    init(from report: PieFedCommentReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.commentReport.id
        self.created = report.commentReport.published

        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.commentReport.updated
        self.resolved = report.commentReport.resolved
        self.reason = report.commentReport.reason ?? ""
        
        self.target = try .comment(.init(from: report))
    }
    
    init(from report: PieFedPostReportView) throws(ApiClientError) {
        self.creator = try .init(from: report.creator)
        
        self.id = report.postReport.id
        self.created = report.postReport.published
        
        if let resolver = report.resolver {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        
        self.updated = report.postReport.updated
        self.resolved = report.postReport.resolved
        self.reason = report.postReport.reason
        
        self.target = try .post(.init(from: report))
    }
}
