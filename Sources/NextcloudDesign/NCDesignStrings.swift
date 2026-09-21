// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

nonisolated extension LocalizedStringResource {
    /// Resolves a string against *this package's* bundle.
    ///
    /// Library strings constructed without an explicit bundle silently resolve
    /// against the consuming app's bundle and come back untranslated. That is the
    /// single most common recurring bug in SwiftPM UI libraries, and it fails
    /// quietly, so every library string in this target must go through here.
    internal init(ncDesign key: String.LocalizationValue) {
        self.init(key, table: "Localizable", bundle: .atURL(Bundle.module.bundleURL))
    }
}
