import SwiftUI

struct LevelMeterView: View {
    @ObservedObject var meter: AudioLevelMeter

    private let barWidth:   CGFloat = 44
    private let barGap:     CGFloat = 8
    private let scaleWidth: CGFloat = 26
    private let padding:    CGFloat = 8

    private static let dbMarks: [(String, CGFloat)] = [
        ("0",   1.000),
        ("-3",  0.708),
        ("-6",  0.501),
        ("-12", 0.251),
        ("-24", 0.063)
    ]

    private static let gradient = Gradient(stops: [
        .init(color: .green,  location: 0.0),
        .init(color: .yellow, location: 0.501),
        .init(color: .red,    location: 0.708)
    ])

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                scaleColumn
                barsCanvas
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: barGap) {
                Text("L")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: barWidth, alignment: .center)
                Text("R")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: barWidth, alignment: .center)
            }
            .padding(.leading, scaleWidth)
            .padding(.top, 4)
            .padding(.bottom, 2)
        }
        .padding(padding)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.14, green: 0.14, blue: 0.16))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.6), lineWidth: 8)
                    .blur(radius: 5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        .contentShape(Rectangle())
        .onTapGesture { meter.resetClip() }
    }

    private var scaleColumn: some View {
        GeometryReader { geo in
            let h = geo.size.height
            ZStack(alignment: .topTrailing) {
                ForEach(Self.dbMarks, id: \.0) { label, frac in
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .offset(y: max(0, h * (1.0 - frac) - 5))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: scaleWidth)
    }

    private var barsCanvas: some View {
        let ll = meter.leftLevel
        let rl = meter.rightLevel
        let lp = meter.leftPeak
        let rp = meter.rightPeak
        let bw = barWidth
        let bg = barGap

        return Canvas { ctx, size in
            let h = size.height

            for (_, frac) in Self.dbMarks {
                let y = h * (1.0 - frac)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(path, with: .color(.white.opacity(0.12)), lineWidth: 1)
            }

            let channels: [(CGFloat, Float, Float)] = [
                (0,       ll, lp),
                (bw + bg, rl, rp)
            ]

            for (x, level, peak) in channels {
                ctx.fill(
                    Path(CGRect(x: x, y: 0, width: bw, height: h)),
                    with: .color(Color(nsColor: .separatorColor).opacity(0.3))
                )
                let levelH = h * CGFloat(min(level, 1.0))
                if levelH > 0 {
                    ctx.fill(
                        Path(CGRect(x: x, y: h - levelH, width: bw, height: levelH)),
                        with: .linearGradient(
                            Self.gradient,
                            startPoint: CGPoint(x: x, y: h),
                            endPoint:   CGPoint(x: x, y: 0)
                        )
                    )
                }
                if peak > 0 {
                    let peakY = h * (1.0 - CGFloat(min(peak, 1.0)))
                    ctx.fill(
                        Path(CGRect(x: x, y: peakY, width: bw, height: 2)),
                        with: .color(peak >= 1.0 ? .red : .white)
                    )
                }
            }
        }
        .frame(width: barWidth * 2 + barGap)
    }
}
