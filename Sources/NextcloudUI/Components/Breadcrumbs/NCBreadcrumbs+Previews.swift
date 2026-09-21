// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

private let previewPath = [
    NCBreadcrumbSegment(id: "/", title: "Files"),
    NCBreadcrumbSegment(id: "/work", title: "Work"),
    NCBreadcrumbSegment(id: "/work/2026", title: "2026"),
    NCBreadcrumbSegment(id: "/work/2026/q3", title: "Q3"),
    NCBreadcrumbSegment(id: "/work/2026/q3/reports", title: "Reports"),
]

private let previewArabicPath = [
    NCBreadcrumbSegment(id: "/", title: "الملفات"),
    NCBreadcrumbSegment(id: "/work", title: "العمل"),
    NCBreadcrumbSegment(id: "/work/2026", title: "٢٠٢٦"),
    NCBreadcrumbSegment(id: "/work/2026/reports", title: "التقارير"),
]

/// The same path at three widths, so the collapse is visible as one picture
/// rather than three previews.
private struct NCBreadcrumbsPreview: View {
    var segments: [NCBreadcrumbSegment] = previewPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach([440.0, 280.0, 150.0], id: \.self) { width in
                NCBreadcrumbs(segments) { _ in }
                    .frame(width: width)
            }
        }
        .padding()
    }
}

#Preview("Breadcrumbs / collapsing", traits: .ncTheme) {
    NCBreadcrumbsPreview()
}

#Preview("Breadcrumbs / long content", traits: .ncTheme) {
    NCBreadcrumbs([
        NCBreadcrumbSegment(id: "/", title: "Files"),
        NCBreadcrumbSegment(id: "/a", title: "Engineering handover documentation"),
        NCBreadcrumbSegment(id: "/a/b", title: "Quarterly reporting and reconciliation"),
        NCBreadcrumbSegment(id: "/a/b/c", title: "Attachments awaiting legal review"),
    ]) { _ in }
    .frame(width: 320)
    .padding()
}

#Preview("Breadcrumbs / empty", traits: .ncTheme) {
    // No segments draws nothing at all, rather than a stray chevron.
    NCBreadcrumbs([]) { _ in }
        .frame(width: 320, height: 24)
        .padding()
}

#Preview("Breadcrumbs / single segment", traits: .ncTheme) {
    NCBreadcrumbs([NCBreadcrumbSegment(id: "/", title: "Files")]) { _ in }
        .frame(width: 320)
        .padding()
}

#Preview("Breadcrumbs / dark", traits: .ncTheme) {
    NCBreadcrumbsPreview().preferredColorScheme(.dark)
}

#Preview("Breadcrumbs / increased contrast", traits: .ncIncreasedContrast) {
    NCBreadcrumbsPreview()
}

// The trail reverses and the chevrons mirror. This is the preview that matters
// most in the wave: a breadcrumb that keeps pointing left to right in Arabic
// reads as a path running backwards.
#Preview("Breadcrumbs / RTL", traits: .ncTheme) {
    NCBreadcrumbsPreview(segments: previewArabicPath)
        .environment(\.layoutDirection, .rightToLeft)
}

#endif
