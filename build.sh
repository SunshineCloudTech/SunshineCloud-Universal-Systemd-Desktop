DESKTOP=kde
for DIST in debian-* ubuntu-*; do
    [ -d "$DIST" ] || continue
    CODENAME=${DIST##*-}
    DF="Dockerfile.${CODENAME}-${DESKTOP}"
    if [ -f "$DIST/$DF" ]; then
        echo "==> Building $DIST-$DESKTOP using $DIST/$DF"
        docker build -t "${DIST}-${DESKTOP}" -f "$DIST/$DF" .
    else
        echo "!! Missing $DIST/$DF, skip"
    fi
done
