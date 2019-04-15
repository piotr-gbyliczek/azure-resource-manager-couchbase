# az acr login --name wsinternalcontainerregistry
docker pull wsinternalcontainerregistry.azurecr.io/revapi:latest
cd docker
docker-compose down
docker-compose up -d
