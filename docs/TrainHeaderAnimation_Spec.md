# Train Header Animation Spec (Portable SwiftUI + Jetpack Compose)

> **Purpose:** Define a lightweight, fully-native **SwiftUI** header animation that can be ported to **Android Jetpack Compose** with near-identical motion by sharing the same *time-based math* and deterministic particle generation.

---

## 1. Goals

- Create a **wide, looping header animation** (mobile screen width) with a low-poly steam train vibe.
- Keep everything **SwiftUI-native** (Option B: procedural 2D overlay) while making the logic **portable** to Android.
- Avoid heavy 3D frameworks unless needed.
- Maintain stable performance (60fps target; graceful 30fps).

---

## 2. Visual Summary

A wide header banner where:

- The **train subtly bobs** (tiny vertical motion).
- Optional **micro-rotation** (very subtle).
- **Smoke puffs** emit from the stack, drift up/back, expand, and fade out.
- Optional **gentle parallax** (single-image pan or multi-layer drift).

---

## 3. Asset Strategy

### 3.1 Minimum viable (single flattened image)
- `train_header_base.png` (wide banner)
- Procedural smoke drawn on top (no asset splitting required)

### 3.2 Recommended (layered images for best results)
Provide PNGs (transparent where appropriate):

1. `bg.png` (sky/mountains)
2. `mid.png` (trees/rocks)
3. `train.png` (train body)
4. `track.png` (optional repeating strip)
5. `wheel_*.png` (optional separate wheels)

> If you can only split one layer: **train.png** + **bg.png**.

---

## 4. Layout Requirements

### 4.1 Header sizing
- Width: **100% of screen**
- Height: `min(220dp, width * 0.45)` (Android) / `min(220pt, width * 0.45)` (iOS)
- Content scale: **center-crop** horizontally (banner feel)

### 4.2 Safe-area behavior
- iOS: may extend under status bar (hero header), but keep critical art below top padding.
- Android: respect system insets if placed at top.

---

## 5. Portable Animation Model (Shared Math)

### 5.1 Single time variable
- Use `t` as continuous time in **seconds**.
- Define:
  - `loopPeriod = 6.0` seconds
  - `phase = (t % loopPeriod) / loopPeriod` in **[0, 1)**

All motion derives from `(t, phase)`.

---

## 6. Motion Components

### 6.1 Train bob
- Vertical offset:
  - `bobY = sin(2π * phase) * 2.0` px
- Optional tiny rotation:
  - `bobRot = sin(2π * phase + π/2) * 0.3` degrees

### 6.2 Parallax (two approaches)

#### A) Single-image gentle pan (no layers)
- `panX = sin(2π * phase) * 6px`

#### B) Multi-layer drift (layered assets)
- `bgX  = -phase * 6px`
- `midX = -phase * 10px`
- `fgX  = -phase * 14px`

> Drift is small; resetting each loop is visually acceptable.

---

## 7. Smoke Particle System (Procedural + Deterministic)

### 7.1 Requirements
- Deterministic across platforms.
- No random calls during draw; all “randomness” derived from `particleId` via hash function.

### 7.2 Constants (tuning knobs)
- `emitRate = 7 particles/sec`
- `maxParticles ≈ emitRate * life` (cap ~40)
- `life = 2.2 sec`
- `emitPosNormalized = (0.63, 0.38)` (normalized in header coordinates; tweak per art)
- Drift:
  - `windX = -14 px/sec`
  - `riseY  = -22 px/sec`
- `smokeGlobalAlpha = 0.85`

### 7.3 Deterministic emission
- `particleId` increments per puff.
- `birthTime = particleId / emitRate`
- Alive if `age = (t - birthTime)` in `[0, life]`
- Normalize:
  - `u = age / life` in **[0, 1]**

### 7.4 Per-particle variation (seeded)
Use deterministic function:

- `rand01(id, salt)` → float in **[0, 1)**

Derived values:
- `startRadius = lerp(6, 10, rand01(id, 1))`
- `endRadius   = startRadius + lerp(10, 18, rand01(id, 2))`
- `wobbleAmp   = lerp(2, 6, rand01(id, 3))`
- `wobbleFreq  = lerp(0.8, 1.6, rand01(id, 4))`
- `wobblePhase = rand01(id, 5) * 2π`

### 7.5 Particle position
Let:
- `x0 = emitPosNormalized.x * width`
- `y0 = emitPosNormalized.y * height`

Then:
- `x = x0 + windX * age + sin(age * wobbleFreq + wobblePhase) * wobbleAmp`
- `y = y0 + riseY * age`

### 7.6 Particle size
- `r = lerp(startRadius, endRadius, easeOutQuad(u))`
- `easeOutQuad(u) = 1 - (1-u)^2`

### 7.7 Opacity envelope
Fade in quickly then fade out:
- `alpha = smoothstep(0.0, 0.12, u) * (1 - smoothstep(0.65, 1.0, u))`
- Final alpha = `alpha * smokeGlobalAlpha`

### 7.8 Color
- Near-white w/ slight gray using `shade`:
  - `shade = lerp(0.85, 1.0, smoothstep(0.0, 0.5, u))`
- Color = `(shade, shade, shade, finalAlpha)`

### 7.9 Draw order
- Smoke is drawn **above train art** but **below any UI text** on top of the header.

---

## 8. Performance Targets

- Keep total particles to ~40.
- Avoid blur filters; use simple filled circles/ellipses.
- Skip particles if offscreen or alpha is near-zero.
- Keep draw calls low (1–3 images + smoke circles).

---

## 9. Accessibility: Reduce Motion

### iOS
- Use `@Environment(\.accessibilityReduceMotion)` to disable smoke and bob/pan.

### Android
- Consider system animator scale / reduce-motion equivalents.
- Provide a flag to disable animation or reduce emit rate to 0.

---

## 10. Acceptance Criteria

1. Header fills screen width and looks good on small and large phones.
2. Smoke appears from the stack, rises, drifts left, expands, and fades naturally.
3. No visible “popping” when the loop resets (time-based IDs should avoid this).
4. Runs smoothly on mid-tier devices (no stutter).
5. Reduce Motion disables or greatly reduces animation.

---

## 11. Implementation Reference

### 11.1 Shared deterministic math (Swift)

Create `PortableAnimMath.swift`:

```swift
import Foundation
import CoreGraphics

enum AnimMath {
    static let twoPi = CGFloat.pi * 2

    // Deterministic hash -> 0...1 (portable-ish). Uses 32-bit ops like Kotlin's UInt.
    static func rand01(_ id: Int, _ salt: UInt32) -> CGFloat {
        var x = UInt32(bitPattern: Int32(id)) &* 0x9E3779B9
        x &+= salt &* 0x85EBCA6B
        x ^= (x >> 16)
        x &*= 0x7FEB352D
        x ^= (x >> 15)
        x &*= 0x846CA68B
        x ^= (x >> 16)
        let v = x & 0x00FF_FFFF
        return CGFloat(v) / CGFloat(0x0100_0000) // [0,1)
    }

    static func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
    static func clamp01(_ x: CGFloat) -> CGFloat { max(0, min(1, x)) }

    static func smoothstep(_ e0: CGFloat, _ e1: CGFloat, _ x: CGFloat) -> CGFloat {
        let t = clamp01((x - e0) / (e1 - e0))
        return t * t * (3 - 2 * t)
    }

    static func easeOutQuad(_ u: CGFloat) -> CGFloat {
        let t = clamp01(u)
        return 1 - (1 - t) * (1 - t)
    }
}
```

### 11.2 Shared deterministic math (Kotlin)

Create `PortableAnimMath.kt`:

```kotlin
import kotlin.math.*

object AnimMath {
    const val TWO_PI = (Math.PI * 2.0).toFloat()

    fun rand01(id: Int, salt: UInt): Float {
        var x = id.toUInt() * 0x9E3779B9u
        x += salt * 0x85EBCA6Bu
        x = x xor (x shr 16)
        x *= 0x7FEB352Du
        x = x xor (x shr 15)
        x *= 0x846CA68Bu
        x = x xor (x shr 16)
        val v = x and 0x00FF_FFFFu
        return v.toFloat() / 0x0100_0000u.toFloat()
    }

    fun lerp(a: Float, b: Float, t: Float): Float = a + (b - a) * t
    fun clamp01(x: Float): Float = max(0f, min(1f, x))

    fun smoothstep(e0: Float, e1: Float, x: Float): Float {
        val t = clamp01((x - e0) / (e1 - e0))
        return t * t * (3f - 2f * t)
    }

    fun easeOutQuad(u: Float): Float {
        val t = clamp01(u)
        return 1f - (1f - t) * (1f - t)
    }
}
```

---

## 12. SwiftUI Reference Implementation (Canvas Overlay)

Assumes `train_header_base` exists in iOS Assets.

```swift
import SwiftUI

struct TrainHeaderView: View {
    // Tuning knobs
    let loopPeriod: Double = 6.0
    let emitRate: Double = 7.0
    let life: Double = 2.2
    let windX: CGFloat = -14.0
    let riseY: CGFloat  = -22.0
    let smokeGlobalAlpha: CGFloat = 0.85
    let emitPosNormalized = CGPoint(x: 0.63, y: 0.38)

    let bobAmplitudePx: CGFloat = 2.0
    let bobRotationDeg: CGFloat = 0.3
    let panAmplitudePx: CGFloat = 6.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = min(220.0, w * 0.45)

            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let phase = (t.truncatingRemainder(dividingBy: loopPeriod)) / loopPeriod

                let bobY = reduceMotion ? 0 : CGFloat(sin(2 * Double.pi * phase)) * bobAmplitudePx
                let bobRot = reduceMotion ? 0 : CGFloat(sin(2 * Double.pi * phase + Double.pi/2)) * bobRotationDeg
                let panX = reduceMotion ? 0 : CGFloat(sin(2 * Double.pi * phase)) * panAmplitudePx

                ZStack {
                    Image("train_header_base")
                        .resizable()
                        .scaledToFill()
                        .frame(width: w, height: h)
                        .clipped()
                        .offset(x: panX, y: bobY)
                        .rotationEffect(.degrees(Double(bobRot)))

                    Canvas { context, size in
                        guard !reduceMotion else { return }

                        let x0 = emitPosNormalized.x * size.width
                        let y0 = emitPosNormalized.y * size.height

                        let maxId = Int(floor(t * emitRate))
                        let minId = max(0, Int(floor((t - life) * emitRate)) - 2)

                        for id in minId...maxId {
                            let birthTime = Double(id) / emitRate
                            let age = t - birthTime
                            if age < 0 || age > life { continue }

                            let u = CGFloat(age / life)

                            let startR = AnimMath.lerp(6, 10, AnimMath.rand01(id, 1))
                            let endR   = startR + AnimMath.lerp(10, 18, AnimMath.rand01(id, 2))
                            let wobbleAmp  = AnimMath.lerp(2, 6, AnimMath.rand01(id, 3))
                            let wobbleFreq = AnimMath.lerp(0.8, 1.6, AnimMath.rand01(id, 4))
                            let wobblePhase = AnimMath.rand01(id, 5) * AnimMath.twoPi

                            let x = x0 + windX * CGFloat(age)
                                + sin(CGFloat(age) * wobbleFreq + wobblePhase) * wobbleAmp
                            let y = y0 + riseY * CGFloat(age)

                            let r = AnimMath.lerp(startR, endR, AnimMath.easeOutQuad(u))
                            let a = AnimMath.smoothstep(0.0, 0.12, u) *
                                    (1 - AnimMath.smoothstep(0.65, 1.0, u))
                            if a <= 0.001 { continue }

                            let shade = AnimMath.lerp(0.85, 1.0, AnimMath.smoothstep(0.0, 0.5, u))
                            let color = Color(.sRGB, red: Double(shade), green: Double(shade), blue: Double(shade),
                                              opacity: Double(a * smokeGlobalAlpha))

                            let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                            context.fill(Path(ellipseIn: rect), with: .color(color))
                        }
                    }
                    .frame(width: w, height: h)
                    .allowsHitTesting(false)
                }
                .frame(width: w, height: h)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .frame(height: min(220.0, UIScreen.main.bounds.width * 0.45))
    }
}
```

---

## 13. Jetpack Compose Reference Implementation (Canvas Overlay)

Assumes `train_header_base.png` in `res/drawable` as `R.drawable.train_header_base`.

```kotlin
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.isActive
import kotlin.math.*

@Composable
fun TrainHeaderView(
    modifier: Modifier = Modifier
) {
    val loopPeriod = 6.0f
    val emitRate = 7.0f
    val life = 2.2f
    val windX = -14.0f
    val riseY = -22.0f
    val smokeGlobalAlpha = 0.85f
    val emitPosNormalized = Offset(0.63f, 0.38f)

    val bobAmplitudePx = 2.0f
    val panAmplitudePx = 6.0f

    var t by remember { mutableStateOf(0f) }
    LaunchedEffect(Unit) {
        val start = withFrameNanos { it }
        while (isActive) {
            val now = withFrameNanos { it }
            t = (now - start) / 1_000_000_000f
        }
    }

    BoxWithConstraints(modifier = modifier.fillMaxWidth()) {
        val targetHeightDp = minOf(220.dp, (maxWidth * 0.45f))
        val phase = ((t % loopPeriod) / loopPeriod)

        val bobY = sin(AnimMath.TWO_PI * phase) * bobAmplitudePx
        val panX = sin(AnimMath.TWO_PI * phase) * panAmplitudePx

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(targetHeightDp)
                .clip(androidx.compose.foundation.shape.RoundedCornerShape(16.dp))
        ) {
            Image(
                painter = painterResource(id = R.drawable.train_header_base),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxSize()
                    .offset(
                        x = with(LocalDensity.current) { panX.toDp() },
                        y = with(LocalDensity.current) { bobY.toDp() }
                    )
            )

            androidx.compose.foundation.Canvas(modifier = Modifier.fillMaxSize()) {
                val x0 = emitPosNormalized.x * size.width
                val y0 = emitPosNormalized.y * size.height

                val maxId = floor(t * emitRate).toInt()
                val minId = max(0, floor((t - life) * emitRate).toInt() - 2)

                for (id in minId..maxId) {
                    val birthTime = id / emitRate
                    val age = t - birthTime
                    if (age < 0f || age > life) continue

                    val u = age / life

                    val startR = AnimMath.lerp(6f, 10f, AnimMath.rand01(id, 1u))
                    val endR = startR + AnimMath.lerp(10f, 18f, AnimMath.rand01(id, 2u))
                    val wobbleAmp = AnimMath.lerp(2f, 6f, AnimMath.rand01(id, 3u))
                    val wobbleFreq = AnimMath.lerp(0.8f, 1.6f, AnimMath.rand01(id, 4u))
                    val wobblePhase = AnimMath.rand01(id, 5u) * AnimMath.TWO_PI

                    val x = x0 + windX * age + sin(age * wobbleFreq + wobblePhase) * wobbleAmp
                    val y = y0 + riseY * age

                    val r = AnimMath.lerp(startR, endR, AnimMath.easeOutQuad(u))
                    val a = AnimMath.smoothstep(0.0f, 0.12f, u) *
                            (1f - AnimMath.smoothstep(0.65f, 1.0f, u))
                    if (a <= 0.001f) continue

                    val shade = AnimMath.lerp(0.85f, 1.0f, AnimMath.smoothstep(0.0f, 0.5f, u))
                    val color = Color(shade, shade, shade, a * smokeGlobalAlpha)

                    drawCircle(
                        color = color,
                        radius = r,
                        center = Offset(x, y)
                    )
                }
            }
        }
    }
}
```

---

## 14. Tuning Checklist

1. Adjust `emitPosNormalized` until smoke aligns with smokestack.
2. If smoke is too large:
   - reduce `endRadius` growth or reduce `startRadius`
3. If smoke is too chaotic:
   - reduce `wobbleAmp` or `wobbleFreq`
4. If smoke is too busy:
   - lower `emitRate` to 4–5
5. If drift direction feels wrong:
   - flip `windX` sign
6. If motion is too noticeable:
   - lower `bobAmplitudePx` and `panAmplitudePx`

---

## 15. TODO / Next Enhancements

- [ ] Add layered parallax (bg/mid/train layers).
- [ ] Add wheel rotation (requires wheel layer assets).
- [ ] Add Android “Reduce Motion” toggle or disable animation if animator duration scale is 0.
- [ ] Optional: add a subtle repeating track movement strip.

---

**End of Spec**
