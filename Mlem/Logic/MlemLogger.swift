//
//  MlemLogger.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-31.
//

import Foundation
import OSLog

class MlemLogger {
    private let logger: Logger
    
    required init(file: String = #fileID) {
        self.logger = Logger(subsystem: AppConstants.loggerSubSystem, category: file)
    }
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
}
