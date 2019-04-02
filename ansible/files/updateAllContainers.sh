az acr login --name wsinternalcontainerregistry
docker pull wsinternalcontainerregistry.azurecr.io/revapi:latest
docker pull wsinternalcontainerregistry.azurecr.io/rebrowse:latest
docker pull wsinternalcontainerregistry.azurecr.io/pdf-fragment-service:latest
docker pull wsinternalcontainerregistry.azurecr.io/addin:latest
docker pull wsinternalcontainerregistry.azurecr.io/lock-monitor:latest

cd docker
docker-compose down
docker-compose up -d
docker system prune -af

