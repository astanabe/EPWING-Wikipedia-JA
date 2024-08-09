CURDIR=`pwd` || exit $?
NCPU=`grep -c processor /proc/cpuinfo` || exit $?
#install requirements
sudo apt install -y build-essential coreutils gzip bzip2 lbzip2 unzip mimetex libimage-magick-perl zlib1g-dev wget || exit $?
#retrieve wikipedia-fpw and extract
wget -c http://green.ribbon.to/~ikazuhiro/dic/files/wikipedia-fpw-20091202-src.tar.gz || exit $?
tar -xzf wikipedia-fpw-20091202-src.tar.gz || exit $?
#install freepwing
wget -c ftp://ftp.sra.co.jp/pub/misc/freepwing/freepwing-1.6.1.tar.bz2 || exit $?
tar -xjf freepwing-1.6.1.tar.bz2 || exit $?
cd freepwing-1.6.1 || exit $?
./configure --prefix=$CURDIR --with-perllibdir=$CURDIR/wikipedia-fpw-20091202 || exit $?
make -j$NCPU || exit $?
make install || exit $?
make clean || exit $?
cd .. || exit $?
rm -rf freepwing-1.6.1 || exit $?
#install eb
wget -c https://github.com/mistydemeo/eb/releases/download/v4.4.3/eb-4.4.3.tar.bz2 || exit $?
tar -xjf eb-4.4.3.tar.bz2 || exit $?
cd eb-4.4.3 || exit $?
./configure --prefix=$CURDIR || exit $?
make -j$NCPU || exit $?
make install || exit $?
make clean || exit $?
cd .. || exit $?
rm -rf eb-4.4.3 || exit $?
#make EPWING data using wikipedia-fpw
cd wikipedia-fpw-20091202 || exit $?
#retrieve dump data of Wikipedia-JA
wget -c https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-pages-articles.xml.bz2 || exit $?
#retrieve SHA1 checksum file
wget -c https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-sha1sums.txt || exit $?
#modify checksum file
perl -i -npe 's/(\sjawiki)-(\d{8})-/$1-latest-/;if($.==1){print(STDERR "$2\n")}' jawiki-latest-sha1sums.txt 2> date.txt || exit $?
DATE=`cat date.txt` || exit $?
#test SHA1 checksum
sha1sum --ignore-missing -c jawiki-latest-sha1sums.txt || exit $?
#extract XML
lbzip2 -d jawiki-latest-pages-articles.xml.bz2 || exit $?
#change file name
mv jawiki-latest-pages-articles.xml wikipedia.xml || exit $?
#modify wikipedia-fpw.conf
perl -i -npe 's/mimetex\.exe/\/usr\/bin\/mimetex/;s/(math_black.*) 1/$1 0/;s/\^\(Wikipedia\|MediaWiki\|Template\|WP\|Portal\|Category\|Help\|Image\|画像\|ファイル\):/^(Wikipedia|MediaWiki|Template|WP|Portal|Category|Help|Image|画像|ファイル|特別|モジュール|PJ|プロジェクト):/' wikipedia-fpw.conf || exit $?
#modify catalogs.txt
perl -npe 's/(Title\s*=\s*).+/$1"Ｗｉｋｉｐｅｄｉａ（ｊａ）"/;s/(Directory\s*=\s*)\S+/$1"WIKIPJA"/' catalogs.txt > catalogs.temp || exit $?
iconv -f utf8 -t euc-jp catalogs.temp > catalogs.txt || exit $?
#modify Makefile
perl -i -npe "s/^DIR = WIKIP/DIR = WIKIPJA/;s/^PACKAGE = wikipedia-fpw-20091202/PACKAGE = EPWING-Wikipedia-JA-$DATE/" Makefile || exit $?
#perform convert
PERL_USE_UNSAFE_INC=1 $CURDIR/bin/fpwmake -j$NCPU || exit $?
PERL_USE_UNSAFE_INC=1 $CURDIR/bin/fpwmake catalogs || exit $?
PERL_USE_UNSAFE_INC=1 $CURDIR/bin/fpwmake -j$NCPU INSTALLDIR=".." HASH_MOD=BDB FPWLINKMOD=BDB install || exit $?
PERL_USE_UNSAFE_INC=1 $CURDIR/bin/fpwmake clean || exit $?
cd .. || exit $?
rm -rf wikipedia-fpw-20091202 || exit $?
chmod 777 WIKIPJA || exit $?
#retrieve gaiji map
wget -c -O gai16_xbm.zip https://ftp.iij.ad.jp/pub/osdn.jp/boookends/54674/gai16_xbm.zip || exit $?
unzip gai16_xbm.zip || exit $?
mv gai16_xbm/wikip.map WIKIPJA/WIKIPJA.map || exit $?
mv gai16_xbm/wikip.plist WIKIPJA/WIKIPJA.plist || exit $?
rm -rf gai16_xbm || exit $?
#compress ebook
cd WIKIPJA || exit $?
$CURDIR/bin/ebzip -z -f -l 5 || exit $?
cd .. || exit $?
#make package
tar -cf EPWING-Wikipedia-JA-$DATE.tar WIKIPJA || exit $?
rm -rf WIKIPJA || exit $?
split -d -a 2 -b 2000M EPWING-Wikipedia-JA-$DATE.tar EPWING-Wikipedia-JA-$DATE.tar. || exit $?
rm EPWING-Wikipedia-JA-$DATE.tar || exit $?
ls EPWING-Wikipedia-JA-$DATE.tar.* | xargs -P $NCPU -I {} sh -c 'sha256sum {} > {}.sha256 || exit $?' || exit $?
cat EPWING-Wikipedia-JA-$DATE.tar.*.sha256 | gzip -c9 > EPWING-Wikipedia-JA-$DATE.sha256.gz || exit $?
rm EPWING-Wikipedia-JA-$DATE.tar.*.sha256 || exit $?
echo -e "gzip -d EPWING-Wikipedia-JA-$DATE.sha256.gz\nsha256sum -c EPWING-Wikipedia-JA-$DATE.sha256" > checkWIKIPJA-$DATE.sh || exit $?
echo -e "for f in EPWING-Wikipedia-JA-$DATE.tar.*\ndo cat \$f >> EPWING-Wikipedia-JA-$DATE.tar\nrm \$f\ndone" > catWIKIPJA-$DATE.sh || exit $?
