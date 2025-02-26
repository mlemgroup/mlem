//
// Software Name: Mlem
// SPDX-FileCopyrightText: Copyright (c) Mlem Group
// SPDX-License-Identifier: GPL-3.0
//
// This software is distributed under the GNU General Public License v3.0 license,
// the text of which is available at https://www.gnu.org/licenses/gpl-3.0-standalone.html
// or see the "LICENSE" file for more details.
//

import Foundation

extension String {
    /// Returns the localized result string using `self` as key.
    /// - Returns String: The conversion of `self` as `NSLocalizedString`
    func localized() -> String {
        let prefferedLocalization = Bundle.preferredLocalization

        guard let path = Bundle.main.path(forResource: prefferedLocalization, ofType: "lproj") else {
            return NSLocalizedString(self, bundle: Bundle.main, comment: "")
        }

        guard let languageBundle = Bundle(path: path) else {
            return NSLocalizedString(self, bundle: Bundle.main, comment: "")
        }

        return NSLocalizedString(self, tableName: nil, bundle: languageBundle, value: "", comment: "")
    }
}
