eksctl create cluster --name=wanderlust \
                    --region=us-east-1 \
                    --version=1.30 \
                    --without-nodegroup

eksctl utils associate-iam-oidc-provider \
  --region us-east-1 \
  --cluster wanderlust \
  --approve

eksctl create nodegroup --cluster=wanderlust \
                     --region=us-east-1 \
                     --name=wanderlust \
                     --node-type=t2.large \
                     --nodes=2 \
                     --nodes-min=2 \
                     --nodes-max=2 \
                     --node-volume-size=29 \
                     --ssh-access \
                     --ssh-public-key=eks-nodegroup-key 
