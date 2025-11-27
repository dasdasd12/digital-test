#!/usr/bin/env python3
"""
Generate a sine-ROM init file for a design with 24-bit total address depth.

This script generates only the first quadrant (0..pi/2) lookup table entries.

Interpretation and defaults used here (to match your request):
- Total address width = 24 bits (full cycle N = 2^24)
- We only generate one quadrant: entries = 2^(24-2) = 2^22 (4,194,304 lines)
- Logical data width used by the design is 10 bits, but the ROM stores only
    the magnitude (no sign bit) using 9 bits. Therefore stored values range 0..2^9-1.

Output format: hex values (uppercase), one per line, no `0x` prefix — matching the
style of the existing `rom/sine_rom.txt` in this repo.

Usage examples:
    # Generate full quadrant (4,194,304 lines). Ensure you have ~30+ MB free.
    python generate_sin_rom24.py --out ..\\rom\\sin_rom24.txt

    # Generate a small preview (e.g., 256 entries) for verification
    python generate_sin_rom24.py --preview --out preview.txt

Note: Default writes 2^22 entries. This can take some time; progress updates printed
every 100k lines by default.
"""
import sys
import math
import argparse
from time import time


def generate(entries, bits, out_path, fmt='hex', progress_interval=100000):
    max_val = (1 << bits) - 1
    start = time()
    with open(out_path, 'w', encoding='utf8') as f:
        for i in range(entries):
            # angle from 0 .. pi/2 inclusive
            if entries == 1:
                angle = 0.0
            else:
                angle = (math.pi / 2.0) * (i / (entries - 1))
            v = int(round(max_val * math.sin(angle)))
            if fmt == 'hex':
                # Uppercase hex, no 0x prefix
                s = format(v, 'X')
            else:
                s = str(v)
            f.write(s + '\n')
            if (i + 1) % progress_interval == 0:
                elapsed = time() - start
                rate = (i + 1) / elapsed if elapsed > 0 else 0
                print(f"Wrote {i+1:,}/{entries:,} lines ({rate:,.0f} lines/s)")
    total = time() - start
    print(f"Finished writing {entries:,} lines to {out_path} in {total:.1f}s")


def main():
    parser = argparse.ArgumentParser(description='Generate sin_rom24.txt (one quadrant)')
    parser.add_argument('--entries', '-n', type=int, default=(1 << 22),
                        help='Number of quadrant entries (default 2^22 = 4,194,304)')
    parser.add_argument('--bits', '-b', type=int, default=9,
                        help='Bit width of stored values in ROM (default 9 — magnitude only)')
    parser.add_argument('--out', '-o', type=str, default='../rom/sin_rom24.txt',
                        help='Output file path (default ../rom/sin_rom24.txt relative to script)')
    parser.add_argument('--format', choices=('hex','dec'), default='hex', help='Output number format')
    parser.add_argument('--preview', action='store_true', help='Generate a small preview (256 entries) and exit')
    args = parser.parse_args()

    if args.preview:
        entries = 256
    else:
        entries = args.entries

    if entries <= 0:
        print('entries must be > 0')
        sys.exit(1)

    print(f"Generating {entries:,} entries, {args.bits}-bit stored values -> {args.out}")
    generate(entries, args.bits, args.out, fmt=args.format)

if __name__ == '__main__':
    main()
