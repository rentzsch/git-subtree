#!/bin/sh -e

which xmlto > /dev/null || (echo "Please install xmlto!" >&2; exit 1)
which asciidoc > /dev/null || (echo "Please install asciidoc!" >&2; exit 1)
which dpkg-deb > /dev/null || (echo "Please install dpkg-deb!" >&2; exit 1)

ORIGDIR=$(pwd)
SRC=$(cd $(dirname $0) && pwd)
VER=$(cd ${SRC} && git describe | tail --bytes=+2)
OUTFILE="${ORIGDIR}/git-subtree_${VER}.deb"
make -C "${SRC}" doc

tdir=$( mktemp -d )
trap "cd ${ORIGDIR}; rm -rf ${tdir}" EXIT

DEBIAN_DIR="${tdir}/DEBIAN"

make -C "${SRC}" install DESTDIR="${tdir}"


mkdir -p "${DEBIAN_DIR}/"
cat "${SRC}/extra/control" | sed "s/@VERSION@/${VER}/" > "${DEBIAN_DIR}/control"

dpkg-deb --build "${tdir}"
mv "${tdir}.deb" "${OUTFILE}"
echo
echo "Package build complete - output: ${OUTFILE}"
