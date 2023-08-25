//
//  APIPrivateMessageReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-12.
//

import Foundation

//  lemy/crates/db_views/src/structs.rs PrivateMessageReportView
struct APIPrivateMessageReportView: Decodable {
    let privateMessageReport: APIPrivateMessageReport
    let privateMessage: APIPrivateMessage
    let privateMessageCreator: APIPerson
    let creator: APIPerson
    let resolver: APIPerson?
}
