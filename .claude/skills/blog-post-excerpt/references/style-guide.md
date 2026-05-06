# Drawing Style Guide for the 150×150 SVG

These are rendering hints for each drawing style. They are guidance, not a strict template — improvise within the spirit of the style. Every example below is a complete, valid SVG that fits in the YAML front matter.

The constants across all styles:

- `viewBox="0 0 150 150"`, `width="150"`, `height="150"`.
- All attributes use **double quotes** (so outer YAML single quotes work).
- Jargon words appear as `<text>` so they are searchable and readable.
- Colour is always present — even monochrome-leaning styles use a tinted background or accent.

---

## Pencil sketch

Thin grey strokes, light cross-hatching for shadow, muted pastel washes for colour, slight irregularity. Background a near-white cream.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><rect width="150" height="150" fill="#fbf8f1"/><circle cx="75" cy="60" r="34" fill="#d8e6f0" fill-opacity="0.6" stroke="#3a3a3a" stroke-width="0.7"/><path d="M50 90 L100 90 L95 120 L55 120 Z" fill="#f0d8d8" fill-opacity="0.5" stroke="#3a3a3a" stroke-width="0.7"/><g stroke="#3a3a3a" stroke-width="0.4" opacity="0.55"><line x1="55" y1="55" x2="70" y2="70"/><line x1="60" y1="50" x2="75" y2="65"/><line x1="65" y1="48" x2="80" y2="63"/></g><text x="75" y="40" font-family="sans-serif" font-size="11" fill="#222" text-anchor="middle">Functor</text><text x="75" y="108" font-family="sans-serif" font-size="10" fill="#222" text-anchor="middle">Monad</text><text x="75" y="138" font-family="sans-serif" font-size="9" fill="#444" text-anchor="middle">Scala · FP</text></svg>
```

Tips:
- `stroke-width` between 0.4 and 0.8.
- Add 2–4 short hatching lines `<line>` near edges of shapes.
- Pastel fills with `fill-opacity` 0.4–0.6.

---

## Oil painting

Thick saturated strokes, rich palette (deep reds, ochres, umbers, viridian, indigo). No fine detail; let shapes overlap. No outlines.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><rect width="150" height="150" fill="#2c1810"/><path d="M0 100 Q40 70 80 95 T150 90 L150 150 L0 150 Z" fill="#8b3a1f"/><path d="M20 110 Q60 85 100 105 T150 100 L150 150 L20 150 Z" fill="#c2691a" fill-opacity="0.85"/><circle cx="115" cy="40" r="22" fill="#e8b339"/><path d="M30 45 Q50 30 75 40 Q100 50 120 35" stroke="#1f4d3a" stroke-width="9" fill="none" stroke-linecap="round"/><text x="75" y="70" font-family="sans-serif" font-weight="bold" font-size="13" fill="#fef3c7" text-anchor="middle">vLLM</text><text x="75" y="135" font-family="sans-serif" font-size="10" fill="#fef3c7" text-anchor="middle">ROCm · NPU</text></svg>
```

Tips:
- Background a deep dark colour (umber, indigo, forest).
- 3–4 broad overlapping shapes filling most of the canvas.
- One bright highlight (sun, moon, lantern) as a circle.
- Text in cream `#fef3c7` for legibility on dark.

---

## Impressionist

Many small coloured dabs of paint, no outlines, suggestion over definition. Light pastel-bright palette.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><rect width="150" height="150" fill="#e8f0f5"/><g><circle cx="20" cy="30" r="3" fill="#f4a4a4"/><circle cx="35" cy="25" r="3" fill="#f6c896"/><circle cx="55" cy="35" r="3" fill="#a8d8a8"/><circle cx="75" cy="28" r="3" fill="#9ec4e8"/><circle cx="95" cy="32" r="3" fill="#f4a4a4"/><circle cx="115" cy="40" r="3" fill="#f6c896"/><circle cx="130" cy="30" r="3" fill="#c5a8e8"/><circle cx="25" cy="60" r="3" fill="#a8d8a8"/><circle cx="50" cy="65" r="3" fill="#9ec4e8"/><circle cx="100" cy="60" r="3" fill="#f6c896"/><circle cx="125" cy="65" r="3" fill="#f4a4a4"/><circle cx="20" cy="120" r="3" fill="#7ab87a"/><circle cx="40" cy="125" r="3" fill="#5a9e5a"/><circle cx="70" cy="120" r="3" fill="#7ab87a"/><circle cx="100" cy="125" r="3" fill="#5a9e5a"/><circle cx="130" cy="120" r="3" fill="#7ab87a"/></g><text x="75" y="90" font-family="sans-serif" font-style="italic" font-size="13" fill="#2a4a6a" text-anchor="middle">Kafka</text><text x="75" y="108" font-family="sans-serif" font-style="italic" font-size="10" fill="#2a4a6a" text-anchor="middle">Spark · Stream</text></svg>
```

Tips:
- 20–40 small dabs (`<circle r="2.5"`) in 4–6 hues.
- Cluster colour by region (sky vs. ground).
- Italic text reads more painterly.

---

## Watercolor

Translucent pools of colour, soft bleeding edges via Gaussian blur, no hard outlines, light off-white paper background.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><defs><filter id="b"><feGaussianBlur stdDeviation="2"/></filter></defs><rect width="150" height="150" fill="#fdfbf6"/><circle cx="55" cy="55" r="38" fill="#9ac4e0" fill-opacity="0.45" filter="url(#b)"/><circle cx="95" cy="75" r="32" fill="#e8a890" fill-opacity="0.45" filter="url(#b)"/><circle cx="70" cy="100" r="28" fill="#c5d89a" fill-opacity="0.45" filter="url(#b)"/><text x="75" y="50" font-family="sans-serif" font-size="11" fill="#2a4a6a" text-anchor="middle">Pandas</text><text x="75" y="78" font-family="sans-serif" font-size="11" fill="#7a3a2a" text-anchor="middle">DataFrame</text><text x="75" y="105" font-family="sans-serif" font-size="9" fill="#3a5a2a" text-anchor="middle">Python</text></svg>
```

Tips:
- 2–3 large overlapping coloured pools at low opacity.
- One shared `feGaussianBlur` filter applied to each pool.
- Text in dark tints of the same hues — it should look like ink on damp paper.

---

## Charcoal

Black and dark-grey rough strokes on cream paper, with smudged low-opacity rectangles for shading. One faint colour accent allowed.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><rect width="150" height="150" fill="#f0ebe0"/><rect x="20" y="40" width="110" height="50" fill="#3a3a3a" fill-opacity="0.15"/><path d="M30 50 L120 50 M30 65 L120 65 M30 80 L120 80" stroke="#1a1a1a" stroke-width="2.5" stroke-linecap="round" opacity="0.85"/><circle cx="115" cy="30" r="8" fill="#c44a3a" fill-opacity="0.7"/><text x="75" y="115" font-family="sans-serif" font-weight="bold" font-size="12" fill="#1a1a1a" text-anchor="middle">HDFS</text><text x="75" y="132" font-family="sans-serif" font-size="9" fill="#3a3a3a" text-anchor="middle">MapReduce · Hadoop</text></svg>
```

Tips:
- Background `#f0ebe0` (sketchpad cream).
- Strokes near-black with `stroke-linecap="round"`.
- One accent colour (red, ochre) at low opacity, no more.

---

## Pop art

Bold flat colours, thick black outlines, optional benday dots, comic-book vibe.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 150 150"><defs><pattern id="d" x="0" y="0" width="6" height="6" patternUnits="userSpaceOnUse"><circle cx="3" cy="3" r="1" fill="#000"/></pattern></defs><rect width="150" height="150" fill="#ffd900"/><rect x="0" y="80" width="150" height="70" fill="#ff3355" stroke="#000" stroke-width="2.5"/><circle cx="105" cy="40" r="22" fill="#3a8eff" stroke="#000" stroke-width="2.5"/><rect x="0" y="80" width="150" height="70" fill="url(#d)" opacity="0.35"/><text x="75" y="50" font-family="sans-serif" font-weight="bold" font-size="14" fill="#000" text-anchor="middle">Lambda</text><text x="75" y="115" font-family="sans-serif" font-weight="bold" font-size="13" fill="#fff" text-anchor="middle">AWS · CDK</text></svg>
```

Tips:
- 3 flat colour zones, all outlined `stroke="#000" stroke-width="2.5"`.
- Optional benday dot pattern overlay at low opacity.
- Bold sans-serif text, no italics.

---

## If the user names a style not listed here

Improvise within these principles:

- Always include colour, even monochrome-leaning styles.
- Always include the jargon as legible `<text>`.
- Use only inline SVG primitives — no embedded raster images, no web fonts.
- Keep the file under ~3 KB so YAML stays readable.

When in doubt, lean on the closest listed style and adjust palette and stroke weight.
