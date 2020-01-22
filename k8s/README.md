# Kubernetes deployment

## To configure:

Create namespace aprsme-dev:  
`kubectl apply -f ./namespace.yaml`

Configure a namespaced context for kubectl: (example using docker w/ kubernetes)  
(Swap out cluster/user for the existing from the result of kubectl config view)  
`kubectl config view`  
`kubectl config current-context`  
`kubectl config set-context dev --namespace=aprsme-dev \\n--cluster=docker-desktop \\n--user=docker-desktop`  
`kubectl config view`  
`kubectl config use-context dev`

Create services  
`kubectl apply -f ./services.yaml`

Check services are configured  
`kubectl get svc`

Create persistant storage volumes  
`kubectl apply -f ./storage.yaml`

Check storage is requested and bound (re-run until complete)  
`kubectl get pvc`

Create deployments  
`kubectl apply -f ./deployments.yaml`

Check pod status  
`kubectl get pod`

Configure Ingress (TBC)


To quickly delete all resources:  
`kubectl delete aprsme-dev`  
This will delete the namespace and everything contained in it.