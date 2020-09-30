#!/bin/bash
echo '{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "sourceMap": true
  }
}' > tsconfig.json;
tsc -p $(echo "$PWD") --watch
