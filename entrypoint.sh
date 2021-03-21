#!/bin/sh

set -e

echo "${INPUT_KEY}" | base64 --decode > "$HOME"/gcloud.json

if [ "${INPUT_ENVFILE}" ]
then
  sed '/^#/ d' < ${INPUT_ENVFILE} > outputFile.txt
  ENVS=$(cat outputFile.txt | xargs | sed 's/\n /,/g')
fi

if [ "${ENVS}" ]
then
    ENV_FLAG="--set-env-vars ${ENVS}"
else
    ENV_FLAG="--clear-env-vars"
fi

ADDITIONAL_ARGS="${ENV_FLAG}"

gcloud auth activate-service-account --key-file="$HOME"/gcloud.json --project "${INPUT_PROJECT}"
gcloud auth configure-docker

IMAGE="${INPUT_REGISTRY}/${INPUT_IMAGE}:${INPUT_TAG}"

echo "Image name ==> ${IMAGE}"
echo "Project ==> ${INPUT_PROJECT}"

docker push "${IMAGE}"

gcloud run deploy "${INPUT_SERVICE}" \
  --image "${IMAGE}" \
  --region "${INPUT_REGION}" \
  --platform managed \
  --allow-unauthenticated \
  ${ADDITIONAL_ARGS}
