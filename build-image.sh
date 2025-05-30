#!/bin/bash

TAGNAME=rdocker

echo "Building multi-platform image..."
docker buildx build -t $TAGNAME \
  --sbom=true --provenance=true \
  --progress=plain \
  --platform linux/amd64,linux/arm64 \
  -f ./Dockerfile \
  .

# Get unique hash for the image
IMAGE_ID=$(docker images -q $TAGNAME | head -n 1)
echo "Image ID: $IMAGE_ID"

echo "Scanning image for vulnerabilities"
rm -rf build/artifacts/
mkdir -p build/artifacts/
docker scout cves --format packages $TAGNAME > build/artifacts/$TAGNAME-scout.txt
docker scout recommendations -o build/artifacts/$TAGNAME-scout-recommendations.txt
docker scout sbom $TAGNAME > build/artifacts/$TAGNAME-sbom.json

syft $TAGNAME -o spdx-json > build/artifacts/$TAGNAME-syft-sbom-spdx.json

#oras attach docker.io/fmlabs/rdocker:latest \
#  --artifact-type application/spdx+json \
#  build/artifacts/$TAGNAME-syft-sbom-spdx.json \
#  sbom.spdx.json:application/spdx+json
