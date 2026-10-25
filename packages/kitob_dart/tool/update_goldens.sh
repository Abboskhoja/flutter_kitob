#!/bin/sh
# Konformans dasturlarini haqiqiy Dart VM'da bajarib, kutilgan natijani yozadi.
cd "$(dirname "$0")/../test/conformance" || exit 1
for f in *.dart; do
  dart run "$f" > "${f%.dart}.expected" 2>&1 || echo "XATO: $f"
done
