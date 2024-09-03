###############################################################
# 1 Tag the public subnet for externet loadbalancer
#    Key: kubernetes.io/role/elb
#    Value: 1

##################################################################################################################################################
# 2 create OICD provider for the cluster
$REGION = "us-east-1"
$CLUSTER_NAME = "mycluster"

# This command is used to associate an IAM OIDC (OpenID Connect) identity provider with an AWS EKS cluster using eksctl, a command-line tool for EKS.
# IAM OIDC identity providers allow for fine-grained IAM role-based access control for applications running in EKS, using Kubernetes service accounts.
# Run only once on the cluster.
eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=$CLUSTER_NAME --approve
 #######################################################################################################
# 3 Create IAM roel for the loadbalancer 
#Download an IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf.
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json" -OutFile "iam_policy.json"



#Create an IAM policy using the policy downloaded in the previous step.
aws iam create-policy `
    --policy-name AWSLoadBalancerControllerIAMPolicy `
    --policy-document file://iam_policy.json

#Create IAM Role using eksctl
$CLUSTER_NAME = "mycluster"
$ACCOUNT_ID = "871909687521"
eksctl create iamserviceaccount `
  --cluster=mycluster `
  --namespace=kube-system `
  --name=aws-load-balancer-controller `
  --role-name AmazonEKSLoadBalancerControllerRole `
  --attach-policy-arn: arn:aws:iam::871909687521:policy/AWSLoadBalancerControllerIAMPolicy `
  --approve

############################################################################################################################################
 Create service account
 kubectl apply -f service-account.yaml

#aws ecr get-login-password --region us-east-1 | \
docker login --username chaganote --password-stdin 871909687521.dkr.ecr.us-east-1.amazonaws.com
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -namespace kube-system \
  --set clusterName=eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

helm install aws-load-balancer-controller eks/aws-load-balancer-controller `
  --namespace kube-system `
  --set clusterName=cluster `
  --set serviceAccount.create=false `
  --set serviceAccount.name=aws-load-balancer-controller


