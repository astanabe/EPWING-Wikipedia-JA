# EPWING-Wikipedia-JA

The JIS X 4081 (EPWING-compatible) format electronic dictionary generated from dump data of ja.wikipedia.org and converter script.
This script is based on the following products.

- [FreePWING](ftp://ftp.sra.co.jp/pub/misc/freepwing/)
- [EB Library](https://github.com/mistydemeo/eb)
- [wikipedia-fpw](http://green.ribbon.to/~ikazuhiro/dic/wikipedia-fpw.html)
- [Dump data of ja.wikipedia.org](https://dumps.wikimedia.org/jawiki/)

## Prerequisites to get dictionary from this repository

1. sh
2. curl or wget
3. gzip
4. sha256sum
5. cat
6. tar
7. EPWING-compatible electronic dictionary viewer such as EBView, EBWin, EBMac or EBPocket

## How to get dictionary from this repository

1. Download `curlWIKIPJA-XXXXXXXX.sh` or `wgetEIKIPJA-XXXXXXXX.sh` from [latest release](https://github.com/astanabe/EPWING-Wikipedia-JA/releases/latest)
2. Run `curlWIKIPJA-XXXXXXXX.sh` or `wgetEIKIPJA-XXXXXXXX.sh` in order to download release files
3. Run file integrity check script `checkWIKIPJA-XXXXXXXX.sh`
4. Run file concatenation script `catWIKIPJA-XXXXXXXX.sh`
5. Run file extraction script `extractWIKIPJA-XXXXXXXX.sh`
6. Then, you will get JIS X 4081 (EPWING-compatible) format electronic dictionary as `WIKIPJA` directory

## Prerequisites to generate dictionary by using this script

1. Debian or Ubuntu
2. sudo
3. enough disk space
4. Internet access

## How to generate dictionary by using this script

1. Run `makeWIKIPJA.sh`
