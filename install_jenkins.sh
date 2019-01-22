gcloud config set compute/zone us-east1-d;
gcloud container clusters create jenkins-cd  --num-nodes 1   --scopes  "https://www.googleapis.com/auth/projecthosting,storage-rw";
gcloud container clusters get-credentials jenkins-cd;
kubectl get pods;
kubectl create ns jenkins;
gcloud compute images create jenkins-home-image --source-uri https://storage.googleapis.com/solutions-public-assets/jenkins-cd/jenkins-home-v3.tar.gz;
gcloud compute disks create jenkins-home --image jenkins-home-image;
PASSWORD=`openssl rand -base64 15`;
echo "Your password is $PASSWORD" ;
sed -i.bak s#CHANGE_ME#$PASSWORD# jenkins/k8s/options;
kubectl create secret generic jenkins --from-file=jenkins/k8s/options --namespace=jenkins;
kubectl apply -f jenkins/k8s/;
sleep 30;
kubectl get pods --namespace jenkins;
kubectl get svc --namespace jenkins;
sleep 5;
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=jenkins/O=jenkins";
kubectl create secret generic tls --from-file=/tmp/tls.crt --from-file=/tmp/tls.key --namespace jenkins;
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account);
#kubectl apply -f jenkins/k8s/lb;
#sleep 10;
#kubectl get ingress --namespace jenkins;
#kubectl describe ingress jenkins --namespace jenkins;



