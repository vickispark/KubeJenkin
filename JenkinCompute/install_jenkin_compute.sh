gcloud config set compute/zone us-central1-a;
gcloud iam service-accounts create jenkins --display-name jenkins;
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:jenkins" --format='value(email)');
export PROJECT=$(gcloud info --format='value(config.project)');
gcloud projects add-iam-policy-binding $PROJECT --role roles/storage.admin --member serviceAccount:$SA_EMAIL;
gcloud projects add-iam-policy-binding $PROJECT --role roles/compute.instanceAdmin.v1 --member serviceAccount:$SA_EMAIL;
gcloud projects add-iam-policy-binding $PROJECT --role roles/compute.networkAdmin --member serviceAccount:$SA_EMAIL;
gcloud projects add-iam-policy-binding $PROJECT --role roles/compute.securityAdmin --member serviceAccount:$SA_EMAIL;
gcloud projects add-iam-policy-binding $PROJECT --role roles/iam.serviceAccountActor --member serviceAccount:$SA_EMAIL;
gcloud iam service-accounts keys create jenkins-sa.json --iam-account $SA_EMAIL;
ls -al ~/.ssh/id_rsa.pub || ssh-keygen -N "" -f  ~/.ssh/id_rsa.pub ;
gcloud compute project-info describe --format=json | jq -r '.commonInstanceMetadata.items[] | select(.key == "ssh-keys") | .value' > sshKeys.pub;
echo "$USER:$(cat ~/.ssh/id_rsa.pub)" >> sshKeys.pub;
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=sshKeys.pub;



