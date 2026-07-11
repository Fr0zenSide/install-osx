// render-toggle-icon.swift — renders the 1024px app icon for "Toggle Desktop Icons.app"
// macOS-style squircle, indigo gradient, white eye.slash SF Symbol.
// Usage: swift render-toggle-icon.swift /path/to/out.png

import AppKit

let S = 1024
guard CommandLine.arguments.count > 1 else {
    fputs("usage: render-toggle-icon.swift <out.png>\n", stderr)
    exit(64)
}
let outPath = CommandLine.arguments[1]

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: S, pixelsHigh: S,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
)!
rep.size = NSSize(width: S, height: S)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let size = CGFloat(S)

// Big Sur icon grid: content squircle inset ~9.6% per side.
let inset = size * 0.096
let rect = NSRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
let radius = rect.width * 0.225
let squircle = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

// Indigo night gradient (matches a "hide the clutter" mood).
let top = NSColor(calibratedRed: 0.36, green: 0.40, blue: 0.58, alpha: 1)
let bottom = NSColor(calibratedRed: 0.11, green: 0.12, blue: 0.24, alpha: 1)
NSGradient(colors: [top, bottom])!.draw(in: squircle, angle: -90)

// Subtle top sheen.
let sheenRect = NSRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2)
let sheen = NSBezierPath(roundedRect: sheenRect, xRadius: radius, yRadius: radius)
NSGradient(colors: [
    NSColor(calibratedWhite: 1.0, alpha: 0.10),
    NSColor(calibratedWhite: 1.0, alpha: 0.0),
])!.draw(in: sheen, angle: -90)

// White eye.slash.fill symbol, centered.
if let sym = NSImage(systemSymbolName: "eye.slash.fill", accessibilityDescription: nil),
   let cfgd = sym.withSymbolConfiguration(.init(pointSize: 460, weight: .semibold)) {
    let tinted = NSImage(size: cfgd.size, flipped: false) { r in
        cfgd.draw(in: r)
        NSColor.white.set()
        r.fill(using: .sourceAtop)
        return true
    }
    let symSize = tinted.size
    let scale = (size * 0.54) / max(symSize.width, symSize.height)
    let w = symSize.width * scale
    let h = symSize.height * scale
    tinted.draw(in: NSRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h))
}

NSGraphicsContext.current?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fputs("PNG encode failed\n", stderr)
    exit(1)
}
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
