# Algorithm Deep Dive

This project shortens URLs by converting a numeric primary key into a short Base62 code.
To reduce predictability, the Base62 alphabet is **shuffled** and stored as a constant.
This keeps the mapping reversible while obscuring sequential IDs.

## Why Base62
- Compact: 62 symbols allow short codes for large ID ranges.
- URL-safe: avoids characters that need encoding.
- Deterministic: given an ID and alphabet, the code is stable.

## Definitions
- **Alphabet**: a 62-character set containing digits and letters in a shuffled order.
- **ID**: the numeric primary key from PostgreSQL.
- **Code**: the Base62 representation of the ID using the shuffled alphabet.

## Encode (ID -> Code)
1. Choose the shuffled alphabet (length 62).
2. Repeatedly divide the ID by 62.
3. Map each remainder to the alphabet.
4. Reverse the collected characters to get the code.

Pseudo:

```text
encode(id, alphabet):
  base = 62
  if id == 0: return alphabet[0]
  chars = []
  while id > 0:
    rem = id % base
    chars.append(alphabet[rem])
    id = id / base
  return reverse(chars).join("")
```

## Decode (Code -> ID)
1. Build a lookup table: character -> index.
2. For each character, multiply the accumulator by 62 and add the index.

Pseudo:

```text
decode(code, alphabet):
  base = 62
  index = {alphabet[i] -> i}
  value = 0
  for ch in code:
    value = value * base + index[ch]
  return value
```

## Properties and Caveats
- **Reversible**: decode(encode(id)) == id.
- **Obfuscation only**: shuffling hides order but is not cryptographic.
- **No collisions**: a bijection exists for all non-negative integers.
- **Stability**: changing the alphabet breaks existing codes.

## Implementation Notes (Planned)
- Store the alphabet in a single place (backend constant or config).
- Provide unit tests for encode/decode symmetry.
- Avoid leaking sequential IDs via predictable alphabets.

## Example (With a Standard Alphabet)
Using a standard (unshuffled) alphabet for illustration only:

```text
alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
encode(125) => "21"
```

Replace the alphabet with the shuffled production alphabet to get real codes.
