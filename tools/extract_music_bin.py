import re
import struct
from pathlib import Path

# Path to the backup ASM file and output directory
ASM_PATH = Path('everland.asm.bak')
OUT_DIR = Path('bin/music')
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Theme order and their short prefixes for pattern names
THEMES = [
    ('OFF',    'of'),
    ('MYTHOS', 'my'),
    ('LORE',   'lo'),
    ('AURORA', 'au'),
    ('SCARY',  'sc'),
    ('TAVERN', 'tv'),
    ('INN',    'in'),
    ('TEMPLE', 'tp'),
    ('FAIRY',  'fa'),
    ('PIRATE', 'pi'),
]

# Helper to parse .byte lines into lists of ints
def parse_bytes(line):
    values = []
    for x in line.split('.byte',1)[1].split(','):
        x = x.strip()
        try:
            values.append(int(x, 0))
        except ValueError:
            # Skip non-numeric values (labels, etc.)
            return None
    return values

def parse_word_ptrs(line):
    # .word label0,label1,label2
    return [x.strip() for x in line.split('.word',1)[1].split(',')]

# Read all lines
with ASM_PATH.open('r', encoding='utf-8') as f:
    lines = f.readlines()

# Build a map of label -> (line index, line)
label_map = {}
for idx, line in enumerate(lines):
    m = re.match(r'([a-zA-Z0-9_]+):', line)
    if m:
        label_map[m.group(1)] = (idx, line)

# Parse all pattern data into a dict: label -> bytes
pattern_data = {}
for label, (idx, line) in label_map.items():
    if '.byte' in line:
        vals = parse_bytes(line)
        if vals is not None:
            pattern_data[label] = vals

# Parse all pointer tables into a dict: label -> [pattern_label,...]
ptr_tables = {}

for label, (idx, line) in label_map.items():
    if '.word' in line:
        ptr_tables[label] = parse_word_ptrs(line)

# Hardcoded theme settings arrays from everland.asm.bak
themeLeadLen   = [9,16,18,12,20,14,16,12,10,12]
themeBassLen   = [18,32,36,24,40,28,32,24,20,24]
themeSparkLen  = [6,8,8,6,10,6,8,8,6,8]
themeLeadWave  = [0x10,0x10,0x20,0x10,0x20,0x10,0x10,0x40,0x10,0x40]
themeBassWave  = [0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10]
themeSparkWave = [0x40,0x40,0x40,0x40,0x80,0x40,0x40,0x40,0x40,0x40]
themeV1SR      = [0xC8,0xC8,0xD8,0xC8,0x46,0xC8,0xC8,0xA8,0x98,0xC8]
themeV2SR      = [0xC8,0xC8,0xC8,0xC8,0x46,0xC8,0xC8,0xC8,0x98,0xC8]
themeV3SR      = [0x88,0x98,0x98,0x98,0x28,0x98,0x88,0x88,0x98,0x88]

# Sparkle pointer tables for themes that use them
sparkle_ptr_table = {
    3: 'auSpkPtr',  # AURORA
    5: 'tvSpkPtr',  # TAVERN
    6: 'inSpkPtr',  # INN
    8: 'faSpkPtr',  # FAIRY
}

# For themes that don't use sparkle, use noSpkPtr
for i in range(10):
    if i not in sparkle_ptr_table:
        sparkle_ptr_table[i] = 'noSpkPtr'

# Write each theme's .BIN file
for idx, (theme, prefix) in enumerate(THEMES):
    # Gather settings
    leadLen   = themeLeadLen[idx]
    bassLen   = themeBassLen[idx]
    sparkLen  = themeSparkLen[idx]
    leadWave  = themeLeadWave[idx]
    bassWave  = themeBassWave[idx]
    sparkWave = themeSparkWave[idx]
    v1SR      = themeV1SR[idx]
    v2SR      = themeV2SR[idx]
    v3SR      = themeV3SR[idx]

    # Pointer tables
    leadPtrs = ptr_tables[f'{prefix}LeadPtr']
    bassPtrs = ptr_tables[f'{prefix}BassPtr']
    spkPtrs  = ptr_tables[sparkle_ptr_table[idx]]

    # Pattern data (3 patterns each, 16 bytes each)
    leadPatterns = b''.join(bytes(pattern_data[l]) for l in leadPtrs)
    bassPatterns = b''.join(bytes(pattern_data[l]) for l in bassPtrs)
    spkPatterns  = b''.join(bytes(pattern_data[l]) for l in spkPtrs)

    # Compose binary: settings (9 bytes), then 9 pattern pointers (6 bytes, not used by loader), then all pattern data
    header = bytes([
        leadLen, bassLen, sparkLen,
        leadWave, bassWave, sparkWave,
        v1SR, v2SR, v3SR
    ])
    # The loader expects the pattern data in order: lead, bass, sparkle
    data = header + leadPatterns + bassPatterns + spkPatterns
    out_path = OUT_DIR / f'THEME_{theme}.BIN'
    with out_path.open('wb') as f:
        f.write(data)
    print(f'Wrote {out_path} ({len(data)} bytes)')
