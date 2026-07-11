// render-toggle-icon-variants.swift — renders N parametric app-icon variants
// for "Toggle Desktop Icons.app". Usage: swift render-toggle-icon-variants.swift <outdir>

import AppKit

let S = 1024
guard CommandLine.arguments.count > 1 else { fputs("usage: <outdir>\n", stderr); exit(64) }
let outDir = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

struct Variant {
    let slug: String
    let topColor: NSColor
    let bottomColor: NSColor
    let symbolName: String
    let symbolColor: NSColor
    let glow: Bool
    let outline: Bool          // thin border squircle (light designs)
    let slashOverlay: Bool     // manual diagonal slash over the symbol
}

let variants: [Variant] = [
    .init(slug: "v1-indigo-night",
          topColor: .init(calibratedRed: 0.36, green: 0.40, blue: 0.58, alpha: 1),
          bottomColor: .init(calibratedRed: 0.11, green: 0.12, blue: 0.24, alpha: 1),
          symbolName: "eye.slash.fill", symbolColor: .white, glow: false, outline: false, slashOverlay: false),
    .init(slug: "v2-sunset-amber",
          topColor: .init(calibratedRed: 0.98, green: 0.62, blue: 0.25, alpha: 1),
          bottomColor: .init(calibratedRed: 0.62, green: 0.16, blue: 0.16, alpha: 1),
          symbolName: "eye.slash.fill", symbolColor: .white, glow: false, outline: false, slashOverlay: false),
    .init(slug: "v3-mint-glass",
          topColor: .init(calibratedRed: 0.66, green: 0.90, blue: 0.82, alpha: 1),
          bottomColor: .init(calibratedRed: 0.16, green: 0.55, blue: 0.52, alpha: 1),
          symbolName: "eye.slash.fill",
          symbolColor: .init(calibratedRed: 0.06, green: 0.20, blue: 0.20, alpha: 1),
          glow: false, outline: false, slashOverlay: false),
    .init(slug: "v4-nebula-glow",
          topColor: .init(calibratedRed: 0.42, green: 0.22, blue: 0.68, alpha: 1),
          bottomColor: .init(calibratedRed: 0.07, green: 0.04, blue: 0.16, alpha: 1),
          symbolName: "eye.slash.fill", symbolColor: .white, glow: true, outline: false, slashOverlay: false),
    .init(slug: "v5-paper-minimal",
          topColor: .init(calibratedWhite: 0.97, alpha: 1),
          bottomColor: .init(calibratedWhite: 0.90, alpha: 1),
          symbolName: "eye.slash",
          symbolColor: .init(calibratedWhite: 0.12, alpha: 1),
          glow: false, outline: true, slashOverlay: false),
    .init(slug: "v6-desktop-duo",
          topColor: .init(calibratedRed: 0.25, green: 0.51, blue: 0.89, alpha: 1),
          bottomColor: .init(calibratedRed: 0.08, green: 0.18, blue: 0.42, alpha: 1),
          symbolName: "menubar.dock.rectangle", symbolColor: .white, glow: false, outline: false, slashOverlay: true),
]

func tinted(_ image: NSImage, _ color: NSColor) -> NSImage {
    NSImage(size: image.size, flipped: false) { r in
        image.draw(in: r)
        color.set()
        r.fill(using: .sourceAtop)
        return true
    }
}

for v in variants {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: S, pixelsHigh: S,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: S, height: S)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let size = CGFloat(S)
    let inset = size * 0.096
    let rect = NSRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
    let radius = rect.width * 0.225
    let squircle = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

    NSGradient(colors: [v.topColor, v.bottomColor])!.draw(in: squircle, angle: -90)

    // top sheen
    let sheenRect = NSRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2)
    NSGradient(colors: [NSColor(calibratedWhite: 1, alpha: 0.10), NSColor(calibratedWhite: 1, alpha: 0)])!
        .draw(in: NSBezierPath(roundedRect: sheenRect, xRadius: radius, yRadius: radius), angle: -90)

    if v.outline {
        let o = squircle.copy() as! NSBezierPath
        o.lineWidth = size * 0.012
        NSColor(calibratedWhite: 0.15, alpha: 0.9).setStroke()
        o.stroke()
    }

    if let sym = NSImage(systemSymbolName: v.symbolName, accessibilityDescription: nil),
       let cfgd = sym.withSymbolConfiguration(.init(pointSize: 460, weight: .semibold)) {
        let t = tinted(cfgd, v.symbolColor)
        let scale = (size * 0.54) / max(t.size.width, t.size.height)
        let w = t.size.width * scale, h = t.size.height * scale
        let drawRect = NSRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h)

        if v.glow {
            NSGraphicsContext.current?.saveGraphicsState()
            let shadow = NSShadow()
            shadow.shadowColor = NSColor(calibratedRed: 0.75, green: 0.55, blue: 1.0, alpha: 0.9)
            shadow.shadowBlurRadius = size * 0.05
            shadow.set()
            t.draw(in: drawRect)
            NSGraphicsContext.current?.restoreGraphicsState()
        }
        t.draw(in: drawRect)

        if v.slashOverlay {
            let slash = NSBezierPath()
            let m = size * 0.30
            slash.move(to: NSPoint(x: m, y: m))
            slash.line(to: NSPoint(x: size - m, y: size - m))
            slash.lineCapStyle = .round
            slash.lineWidth = size * 0.075
            v.bottomColor.setStroke()
            let outlineSlash = slash.copy() as! NSBezierPath
            outlineSlash.lineWidth = size * 0.115
            outlineSlash.stroke()
            slash.lineWidth = size * 0.062
            NSColor.white.setStroke()
            slash.stroke()
        }
    }

    NSGraphicsContext.current?.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "\(outDir)/\(v.slug).png"))
    print("wrote \(v.slug).png")
}
