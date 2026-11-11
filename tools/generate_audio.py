"""Generate four original, short UI sounds with the Python standard library."""
import math
import struct
import wave
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
for name, notes in {'move': [440], 'push': [330, 550], 'blocked': [150, 110], 'win': [523, 659, 784, 1046]}.items():
    samples = []
    for hz in notes:
        length = 0.07 if name == 'move' else 0.11
        count = int(22050 * length)
        for i in range(count):
            envelope = math.sin(math.pi * i / count) ** 2
            value = 0.22 * envelope * math.sin(2 * math.pi * hz * i / 22050)
            samples.append(struct.pack('<h', int(value * 32767)))
    with wave.open(str(ROOT / 'assets' / f'{name}.wav'), 'wb') as out:
        out.setparams((1, 2, 22050, 0, 'NONE', 'not compressed'))
        out.writeframes(b''.join(samples))
