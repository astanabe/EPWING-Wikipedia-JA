# EPWING-Wikipedia-JA

The JIS X 4081 (EPWING-compatible) format electronic dictionary generated from dump data of ja.wikipedia.org and converter script.
This script is based on the following products.

- [FreePWING](ftp://ftp.sra.co.jp/pub/misc/freepwing/)
- [EB Library](https://github.com/mistydemeo/eb)
- [wikipedia-fpw](http://green.ribbon.to/~ikazuhiro/dic/wikipedia-fpw.html)
- [Dump data of ja.wikipedia.org](https://dumps.wikimedia.org/jawiki/)

## How to use

1. Download latest [release files of this package](https://github.com/astanabe/EPWING-Wikipedia-JA/releases)
2. Run file integrity check script `checkWIKIPJA-XXXXXXXX.sh`.
3. Run file concatenation script `catWIKIPJA-XXXXXXXX.sh`.
4. Run file extraction script `extractWIKIPJA-XXXXXXXX.sh`.
5. The, you will get JIS X 4081 (EPWING-compatible) format electronic dictionary as `WIKIPJA` directory.
