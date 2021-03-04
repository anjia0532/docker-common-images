```bash
docker run -d --name mongo-yapi -e MONGO_INITDB_ROOT_USERNAME=yapi -e MONGO_INITDB_ROOT_PASSWORD=yapi mongo

docker run -it --rm --link mongo-yapi:mongo --entrypoint npm --workdir /yapi/vendors -v $PWD\config.json:/yapi/config.json yapi run install-server

docker run -d --name yapi --link mongo-yapi:mongo --workdir /yapi/vendors -p 3000:3000 -v $PWD\config.json:/yapi/config.json yapi server/app.js

```