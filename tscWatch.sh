#!/bin/bash
echo '{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "sourceMap": true
  }
}' > tsconfig.json;
tsc -p $(echo "$PWD") --watch
