#!/bin/sh
sed -i -e 's/js|jsx/xxx/g' ykit.config.js
npm run build-client &
node server/app.js