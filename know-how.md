# error with creating Container App
Chicken-and-egg problem -  Container App is trying to pull my-app:latest from ACR, but that image hasn't been pushed there yet. The registry exists but is empty.

### Log in and push a image
`az acr login --name <container_register_id>`

`docker tag java-spring-app:latest <container_register_id>.azurecr.io/my-app:latest`

`docker push <container_register_id>.azurecr.io/my-app:latest`

### problem with my TF state
there is a wierd problem that my Terraform state is missing something wich is provided in my current infra setup.

`terraform import azurerm_container_app.container-app /subscriptions/<subscription_id>/resourceGroups/rg-java-spring-boot-sample-dev/providers/Microsoft.App/containerApps/ca-java-spring-boot-sample-dev`

# interesting take

## 1
I defined resource containar_app which dont contain something (ingress). When I defined ingress in time where resources are deployed new apply dont make the change.
Probably there is some way.
