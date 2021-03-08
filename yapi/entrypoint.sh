#!/bin/sh
sed -i -e 's/js\|jsx/jsd/g' ykit.config.js
npm run build-client
node server/app.js