. ./setenv.sh

export AWS_ACCESS_KEY_ID=$(cat awsaccess | head -1)
export AWS_SECRET_ACCESS_KEY=$(cat awsaccess | tail -1)

echo '-------Creating a S3 profile secret'
kubectl create secret generic k10-s3-secret \
      --namespace kasten-io \
      --type secrets.kanister.io/aws \
      --from-literal=aws_access_key_id=$(cat awsaccess | head -1) \
      --from-literal=aws_secret_access_key=$(cat awsaccess | tail -1)

echo $OCP_AWS_MY_BUCKET-$(date +%s)$RANDOM > k10_ocp_aws_bucketname

echo '-------Creating a S3 profile'
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Profile
metadata:
  name: $OCP_AWS_MY_OBJECT_STORAGE_PROFILE
  namespace: kasten-io
spec:
  type: Location
  locationSpec:
    credential:
      secretType: AwsAccessKey
      secret:
        apiVersion: v1
        kind: Secret
        name: k10-s3-secret
        namespace: kasten-io
    type: ObjectStore
    objectStore:
      name: $(cat k10_ocp_aws_bucketname)
      objectStoreType: S3
      region: $OCP_AWS_MY_REGION
EOF
