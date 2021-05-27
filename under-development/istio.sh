
# https://blog.alexellis.io/a-bit-of-istio-before-tea-time/ 

# curl -sSLf https://dl.get-arkade.dev/ | sudo sh 

arkade install istio

kubectl create namespace ns-istio

kubectl label namespace ns-istio istio-injection=enabled

kubectl config set-context --current --namespace=ns-istio 

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/bookinfo/platform/kube/bookinfo.yaml 

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/bookinfo/networking/bookinfo-gateway.yaml 


