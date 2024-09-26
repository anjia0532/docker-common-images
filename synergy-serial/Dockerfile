FROM node:lts-alpine

ARG SYNERGY_VERSION=1.1.1

WORKDIR /app

# https://github.com/Richienb/synergy-serial
# https://www.npmjs.com/package/synergy-serial
RUN wget -O /tmp/synergy-serial.tar.gz https://github.com/anjia0532/synergy-serial/archive/refs/tags/v${SYNERGY_VERSION}.tar.gz && \
    tar zxf /tmp/synergy-serial.tar.gz -C /app/ --strip-components 1  && \
    rm -rf /tmp/synergy-serial.tar.gz && \
    cd /app && \
    npm install


# CMD node -e 'const synergySerial = require("synergy-serial");console.log(synergySerial({name: "Humairaa Novak", userLimit: 99, email: "angZh@example.com"}));'

CMD node -e 'const synergySerial = require(".");console.log(synergySerial());'
