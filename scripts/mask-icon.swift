// mask-icon.swift — clip any square artwork into the macOS Big Sur squircle
// with the standard grid inset, on transparent ground. 1024px output.
// Usage: swift mask-icon.swift in.png out.png

import AppKit

let S = 1024
let args = CommandLine.arguments
guard args.count > 2, let src = NSImage(contentsOfFile: args[1]) else {
    fputs("usage: mask-icon.swift <in.png> <out.png>\n", stderr); exit(64)
}

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: S, pixelsHigh: S,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: S, height: S)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let size = CGFloat(S)
let inset = size * 0.096
let rect = NSRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
let squircle = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.225, yRadius: rect.width * 0.225)
squircle.addClip()
// fill the squircle with the artwork (aspect-fill)
src.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)

NSGraphicsContext.current?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
print("wrote \(args[2])")
