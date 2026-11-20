"""Draw the hand-worked tracer boards in docs/tracer-cases/ as SVGs.

Run from the repository root:  python3 docs/tracer-cases/draw_boards.py

Each board in BOARDS gives its size, its pieces, and the beams as worked out
by hand (the cells in order, the color, and how the beam ends). Nothing here
traces anything: the paths are typed in from the answers in README.md, so the
pictures show the expected answers, not what the code does.

Pieces: ("source", dir, color), ("wall",), ("target", color),
("mirror", "-" | "|" | "/" | "\\"), ("splitter", same).
A beam ends "edge:DIR" (runs off the board in DIR), "stop" (ends in its last
cell, marked with a dot) or "loop" (its path closes on itself).
"""
import math, sys

CELL = 64
PAD = 28  # room for row/column labels
COLORS = {
    "red": "#ff2d4b", "green": "#18c25a", "blue": "#2f62ff",
    "yellow": "#ffc61a", "magenta": "#d42ad6", "cyan": "#12b8d6", "white": "#ffffff",
}
CHANNELS = {"red": ["red"], "green": ["green"], "blue": ["blue"],
            "yellow": ["red", "green"], "magenta": ["red", "blue"],
            "cyan": ["green", "blue"], "white": ["red", "green", "blue"]}
DIRS = {"N": (-1, 0), "NE": (-1, 1), "E": (0, 1), "SE": (1, 1), "S": (1, 0),
        "SW": (1, -1), "W": (0, -1), "NW": (-1, -1)}


def centre(r, c):
    return PAD + c * CELL + CELL / 2, PAD + r * CELL + CELL / 2


def tile(x, y, out, fill="#f4f5f9"):
    s = CELL * 0.78
    out.append(f'<rect x="{x - s/2:.1f}" y="{y - s/2:.1f}" width="{s:.1f}" height="{s:.1f}" rx="11" '
               f'fill="{fill}" stroke="#d5d8e2" stroke-width="1" filter="url(#lift)"/>')


def piece_svg(kind, r, c, out, lit_targets):
    x, y = centre(r, c)
    k = kind[0]
    if k == "wall":
        s = CELL * 0.78
        out.append(f'<rect x="{x - s/2:.1f}" y="{y - s/2:.1f}" width="{s:.1f}" height="{s:.1f}" rx="11" '
                   f'fill="url(#wallfill)" filter="url(#lift)"/>')
    elif k == "mirror":
        tile(x, y, out)
        ang = {"-": 0, "|": 90, "/": -45, "\\": 45}[kind[1]]
        L = CELL * 0.62
        out.append(f'<g transform="translate({x:.1f},{y:.1f}) rotate({ang})">'
                   f'<rect x="{-L/2:.1f}" y="-4" width="{L:.1f}" height="8" rx="3" fill="url(#silver)" '
                   f'stroke="#8a90a0" stroke-width="1"/></g>')
    elif k == "source":
        tile(x, y, out)
        d, col = kind[1], COLORS[kind[2]]
        dr, dc = DIRS[d]
        ang = math.degrees(math.atan2(dr, dc))
        out.append(f'<g transform="translate({x:.1f},{y:.1f}) rotate({ang:.1f})">'
                   f'<rect x="-19" y="-10" width="38" height="20" rx="10" fill="#1d2027"/>'
                   f'<line x1="-11" y1="0" x2="5" y2="0" stroke="{col}" stroke-width="2.5" stroke-linecap="round"/>'
                   f'<circle cx="11" cy="0" r="4.6" fill="#fff" stroke="{col}" stroke-width="2.4"/></g>')
    elif k == "target":
        tile(x, y, out)
        want = kind[1]
        lit = (r, c) in lit_targets
        rad = 15
        circ = 2 * math.pi * rad
        chans = CHANNELS[want]
        if lit:
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rad + 6}" fill="{COLORS[want]}" opacity="0.35" filter="url(#glow)"/>')
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="8" fill="{COLORS[want]}" filter="url(#glowsoft)"/>')
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3" fill="#fff"/>')
        else:
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="6" fill="#c9ccd6"/>')
        n = len(chans)
        for i, ch in enumerate(chans):
            seg = circ / n
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rad}" fill="none" stroke="{COLORS[ch]}" '
                       f'stroke-width="3.4" stroke-dasharray="{seg - 3:.1f} {circ - seg + 3:.1f}" '
                       f'stroke-dashoffset="{-i * seg:.1f}" transform="rotate(-90 {x:.1f} {y:.1f})" '
                       f'opacity="{1 if lit else 0.55}"/>')
    elif k == "splitter":
        tile(x, y, out)
        ang = {"-": 0, "|": 90, "/": -45, "\\": 45}[kind[1]]
        L = CELL * 0.62
        out.append(f'<g transform="translate({x:.1f},{y:.1f}) rotate({ang})">'
                   f'<rect x="{-L/2:.1f}" y="-4" width="{L:.1f}" height="8" rx="3" fill="#dfe8ff" '
                   f'stroke="#7d8db8" stroke-width="1" stroke-dasharray="4 3"/></g>')


def beam_points(cells, end, rows, cols):
    pts = [centre(r, c) for r, c in cells]
    if end.startswith("edge:"):
        dr, dc = DIRS[end.split(":")[1]]
        x, y = pts[-1]
        # run on to the board's border in the last direction
        steps = []
        if dr:
            steps.append(((PAD if dr < 0 else PAD + rows * CELL) - y) / dr)
        if dc:
            steps.append(((PAD if dc < 0 else PAD + cols * CELL) - x) / dc)
        t = min(steps)
        pts.append((x + dc * t, y + dr * t))
    return pts


def draw(board, path):
    rows, cols = board["rows"], board["cols"]
    W, H = PAD * 2 + cols * CELL, PAD * 2 + rows * CELL
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" '
           f'font-family="ui-sans-serif, -apple-system, Helvetica, Arial, sans-serif">',
           '<defs>'
           f'<filter id="glow" filterUnits="userSpaceOnUse" x="0" y="0" width="{W}" height="{H}"><feGaussianBlur stdDeviation="5"/></filter>'
           '<filter id="glowsoft" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="2"/></filter>'
           '<filter id="lift" x="-20%" y="-20%" width="140%" height="150%">'
           '<feDropShadow dx="0" dy="1.5" stdDeviation="1.5" flood-color="#1d2340" flood-opacity="0.12"/></filter>'
           '<linearGradient id="silver" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f7f8fb"/>'
           '<stop offset="0.5" stop-color="#b9bfcc"/><stop offset="1" stop-color="#8c93a3"/></linearGradient>'
           '<linearGradient id="wallfill" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4a505e"/>'
           '<stop offset="1" stop-color="#2c3039"/></linearGradient>'
           '<radialGradient id="bg" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="#fbfbfd"/>'
           '<stop offset="1" stop-color="#eceef4"/></radialGradient>'
           '</defs>',
           f'<rect x="{PAD - 6}" y="{PAD - 6}" width="{cols * CELL + 12}" height="{rows * CELL + 12}" rx="14" '
           f'fill="url(#bg)" stroke="#d9dce5"/>']
    for i in range(rows + 1):
        y = PAD + i * CELL
        out.append(f'<line x1="{PAD}" y1="{y}" x2="{PAD + cols * CELL}" y2="{y}" stroke="#dfe2ea" stroke-width="1"/>')
    for j in range(cols + 1):
        x = PAD + j * CELL
        out.append(f'<line x1="{x}" y1="{PAD}" x2="{x}" y2="{PAD + rows * CELL}" stroke="#dfe2ea" stroke-width="1"/>')
    for i in range(rows + 1):
        for j in range(cols + 1):
            out.append(f'<circle cx="{PAD + j * CELL}" cy="{PAD + i * CELL}" r="1.4" fill="#b9bdc9"/>')
    for j in range(cols):
        out.append(f'<text x="{PAD + j * CELL + CELL / 2}" y="{PAD - 11}" font-size="11" fill="#8b90a0" text-anchor="middle">{j}</text>')
    for i in range(rows):
        out.append(f'<text x="{PAD - 12}" y="{PAD + i * CELL + CELL / 2 + 4}" font-size="11" fill="#8b90a0" text-anchor="middle">{i}</text>')
    # beams under the pieces' faces but over the grid
    for cells, col, end in board.get("beams", []):
        pts = beam_points(cells, end, rows, cols)
        d = " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)
        c = COLORS[col]
        out.append(f'<polyline points="{d}" fill="none" stroke="{c}" stroke-width="9" stroke-linecap="round" '
                   f'stroke-linejoin="round" opacity="0.45" filter="url(#glow)"/>')
    for (r, c), kind in board["pieces"].items():
        piece_svg(kind, r, c, out, board.get("lit", set()))
    for cells, col, end in board.get("beams", []):
        pts = beam_points(cells, end, rows, cols)
        d = " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)
        c = COLORS[col]
        out.append(f'<polyline points="{d}" fill="none" stroke="{c}" stroke-width="3" stroke-linecap="round" '
                   f'stroke-linejoin="round"/>')
        if end == "stop":
            x, y = pts[-1]
            out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3.5" fill="{c}"/>')
    # redraw sources and lit targets on top so the beam starts from the pill
    for (r, c), kind in board["pieces"].items():
        if kind[0] in ("source", "target"):
            piece_svg(kind, r, c, out, board.get("lit", set()))
    out.append("</svg>")
    open(path, "w").write("\n".join(out))


def src(d, col):
    return ("source", d, col)


def mir(o):
    return ("mirror", o)


def path(*cells):
    return list(cells)


BOARDS = {
    "01": {"rows": 4, "cols": 5, "pieces": {(2, 1): src("E", "red")},
           "beams": [(path((2, 1), (2, 2), (2, 3), (2, 4)), "red", "edge:E")]},
    "02": {"rows": 3, "cols": 5,
           "pieces": {(1, 0): src("E", "green"), (1, 3): ("wall",)},
           "beams": [(path((1, 0), (1, 1), (1, 2), (1, 3)), "green", "stop")]},
    "03a": {"rows": 3, "cols": 3, "pieces": {(1, 0): src("E", "red"), (1, 1): mir("/")},
            "beams": [(path((1, 0), (1, 1), (0, 1)), "red", "edge:N")]},
    "03b": {"rows": 3, "cols": 3, "pieces": {(1, 2): src("W", "green"), (1, 1): mir("/")},
            "beams": [(path((1, 2), (1, 1), (2, 1)), "green", "edge:S")]},
    "03c": {"rows": 3, "cols": 3, "pieces": {(0, 1): src("S", "blue"), (1, 1): mir("/")},
            "beams": [(path((0, 1), (1, 1), (1, 0)), "blue", "edge:W")]},
    "03d": {"rows": 3, "cols": 3, "pieces": {(2, 1): src("N", "red"), (1, 1): mir("/")},
            "beams": [(path((2, 1), (1, 1), (1, 2)), "red", "edge:E")]},
    "04a": {"rows": 3, "cols": 3, "pieces": {(1, 0): src("E", "blue"), (1, 1): mir("\\")},
            "beams": [(path((1, 0), (1, 1), (2, 1)), "blue", "edge:S")]},
    "04b": {"rows": 3, "cols": 3, "pieces": {(0, 1): src("S", "green"), (1, 1): mir("\\")},
            "beams": [(path((0, 1), (1, 1), (1, 2)), "green", "edge:E")]},
    "05": {"rows": 5, "cols": 5,
           "pieces": {(1, 0): src("E", "red"), (1, 2): mir("-"),
                      (3, 1): src("E", "green"), (3, 3): mir("|")},
           "beams": [(path((1, 0), (1, 1), (1, 2)), "red", "stop"),
                     (path((3, 1), (3, 2), (3, 3), (3, 2), (3, 1), (3, 0)), "green", "edge:W")]},
    "06": {"rows": 3, "cols": 4,
           "pieces": {(1, 0): src("E", "blue"), (1, 2): ("target", "blue")},
           "beams": [(path((1, 0), (1, 1), (1, 2), (1, 3)), "blue", "edge:E")],
           "lit": {(1, 2)}},
    "07": {"rows": 3, "cols": 4,
           "pieces": {(1, 0): src("E", "red"), (1, 2): ("target", "green")},
           "beams": [(path((1, 0), (1, 1), (1, 2), (1, 3)), "red", "edge:E")]},
    "08": {"rows": 3, "cols": 5,
           "pieces": {(1, 0): src("E", "green"), (1, 2): ("target", "green"),
                      (1, 4): ("target", "green")},
           "beams": [(path((1, 0), (1, 1), (1, 2), (1, 3), (1, 4)), "green", "edge:E")],
           "lit": {(1, 2), (1, 4)}},
    "09": {"rows": 4, "cols": 4,
           "pieces": {(0, 2): src("S", "red"), (2, 0): src("E", "green"),
                      (2, 2): ("target", "yellow")},
           "beams": [(path((0, 2), (1, 2), (2, 2), (3, 2)), "red", "edge:S"),
                     (path((2, 0), (2, 1), (2, 2), (2, 3)), "green", "edge:E")],
           "lit": {(2, 2)}},
    "10": {"rows": 4, "cols": 4,
           "pieces": {(2, 2): src("S", "red"), (2, 0): src("E", "green"),
                      (3, 2): ("target", "red")},
           "beams": [(path((2, 0), (2, 1), (2, 2), (2, 3)), "green", "edge:E"),
                     (path((2, 2), (3, 2)), "red", "edge:S")],
           "lit": {(3, 2)}},
    "11": {"rows": 3, "cols": 5,
           "pieces": {(1, 0): src("E", "red"), (1, 2): ("splitter", "/")},
           "beams": [(path((1, 0), (1, 1), (1, 2), (1, 3), (1, 4)), "red", "edge:E"),
                     (path((1, 2), (0, 2)), "red", "edge:N")]},
    "12": {"rows": 5, "cols": 5,
           "pieces": {(1, 2): src("E", "blue"), (1, 1): mir("/"), (1, 3): mir("\\"),
                      (3, 1): mir("\\"), (3, 3): mir("/")},
           "beams": [(path((1, 2), (1, 3), (2, 3), (3, 3), (3, 2), (3, 1), (2, 1),
                           (1, 1), (1, 2)), "blue", "loop")]},
    "13": {"rows": 4, "cols": 5,
           "pieces": {(0, 0): src("SE", "blue"), (2, 2): mir("-")},
           "beams": [(path((0, 0), (1, 1), (2, 2), (1, 3), (0, 4)), "blue", "edge:NE")]},
}

# Boards Victor works out independently get a blank version as well.
BLANK = ["05", "09"]


if __name__ == "__main__":
    import os
    here = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(here, "svg")
    os.makedirs(out, exist_ok=True)
    for name, board in BOARDS.items():
        draw(board, os.path.join(out, f"board-{name}.svg"))
    for name in BLANK:
        b = BOARDS[name]
        draw({"rows": b["rows"], "cols": b["cols"], "pieces": b["pieces"]},
             os.path.join(out, f"board-{name}-blank.svg"))
    print(f"wrote {len(BOARDS) + len(BLANK)} SVGs to {out}")
