// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import CoreGraphics
internal import Foundation
internal import ImageIO
public import SwiftUI

/// Turns image bytes into a SwiftUI `Image`.
///
/// The app fetches the bytes; this package never does. Decoding is separated out
/// because the downsampling path is the one that keeps a message list with two
/// hundred avatars from holding two hundred full-size bitmaps in memory.
public enum NCImageDecoder {

    /// Decodes image data at its natural size.
    ///
    /// Returns `nil` for data that is not a decodable image, rather than
    /// substituting a placeholder: the caller knows what its fallback should be.
    public static func image(from data: Data) -> Image? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil }
        return Image(decorative: cgImage, scale: 1)
    }

    /// Decodes image data, downsampling so that its longest edge is at most
    /// `maximumPixelSize`.
    ///
    /// This decodes straight to the target size rather than decoding full-size
    /// and scaling afterwards, so a 2000px profile photo never becomes a 2000px
    /// bitmap on its way to a 32pt avatar.
    ///
    /// - Parameters:
    ///   - data: The encoded image.
    ///   - maximumPixelSize: The longest edge of the result, in pixels. Pass the
    ///     point size multiplied by the display scale.
    public static func image(from data: Data, maximumPixelSize: Int) -> Image? {
        guard maximumPixelSize > 0 else { return image(from: data) }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
        ]
        guard
            let cgImage = CGImageSourceCreateThumbnailAtIndex(
                source, 0, options as CFDictionary)
        else { return nil }
        return Image(decorative: cgImage, scale: 1)
    }
}
