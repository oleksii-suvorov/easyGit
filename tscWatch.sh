#!/bin/bash
echo '{
  "compilerOptions": {
    "target": "es2020",
    "module": "esnext",
    "sourceMap": false
  }
}' > tsconfig.json;
tsc -p $(echo "$PWD") --watch;
