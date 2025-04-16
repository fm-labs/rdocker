#!/bin/bash

TAGNAME=rdocker:docs
PORT=9000

CMD=$1
if [ -z "$CMD" ]; then
    CMD="build"
fi

case $CMD in
    "build")
        docker build -t ${TAGNAME} -f Dockerfile-docs .
        docker run --rm -it -v $(pwd):/docs ${TAGNAME} build
        ;;

    "serve")
        docker build -t ${TAGNAME} -f Dockerfile-docs .
        docker run --rm -it -v $(pwd):/docs -p ${PORT}:8000 ${TAGNAME}
        echo "Serving on http://localhost:${PORT}"
        ;;
      
    *)
        echo "Usage: $0 {build|serve}"
        exit 1
        ;;
esac
