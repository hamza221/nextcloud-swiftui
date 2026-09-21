// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation

nonisolated extension LocalizedStringResource {
    /// Resolves a string against *this package's* bundle.
    ///
    /// Library strings constructed without an explicit bundle silently resolve
    /// against the consuming app's bundle and come back untranslated. The failure
    /// is quiet -- the English source string is returned, so it looks correct to
    /// an English-speaking developer and is broken for everyone else. It is the
    /// most common recurring bug in SwiftPM UI libraries.
    ///
    /// Every library-owned string must go through here. Caller-supplied data
    /// (a display name, a file name) is a `String` and must *not*: running user
    /// data through a localisation table is how a person called "Cancel" gets
    /// renamed.
    public init(nc key: String.LocalizationValue) {
        self.init(key, table: "Localizable", bundle: .atURL(Bundle.module.bundleURL))
    }
}
