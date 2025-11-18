#!/usr/bin/env bash

base=${1:-containers.intersystems.com/intersystems/iris-community:latest-preview}
tag=$(echo $base | cut -d':' -f2)
if [ -z "$2" ]; then
  target=$(echo $base | rev | cut -d '/' -f 1 | rev | cut -d ':' -f1 )-light
else
  target=${2}
fi
if [ -z "$3" ]; then
  suffix=$(uname -m | sed 's/aarch64/arm64/' | sed 's/x86_64/amd64/')
else
  suffix=${3}
fi
# version=$(docker image inspect --format '{{index .Config.Labels "com.intersystems.platform-version"}}' $base | cut -d'.' -f1-2)
version=2025.3
[[ $tag == 'latest-em' ]] && version='2025.1'
[[ $tag == 'latest-cd' ]] && version='2025.2'

targets="--tag $target:$tag-$suffix "
targets+="--tag $target:$version-$suffix"

originalbase=$(docker history $base --format '{{.CreatedBy}}'  --no-trunc | grep 'LABEL org.opencontainers.image.ref.name=' | cut -d'=' -f2 )
originalbase+=:$(docker history $base --format '{{.CreatedBy}}'  --no-trunc | grep 'LABEL org.opencontainers.image.version=' | cut -d'=' -f2 )

labels=$(docker image inspect --format '{{range $k, $v := .Config.Labels}}--label {{$k}}="{{$v}}" {{end}}' $base)
eval "docker build ${labels} $targets --build-arg BASE_IMAGE=$base --build-arg ORIGINAL_BASE=$originalbase ."

export IMAGES=($target:$tag-$suffix $target:$version-$suffix)
export TAGS=($tag-$suffix $version-$suffix)
echo "Built images:"
echo 'ID Image Size' | awk -F' ' '{printf "%-12s %-70s %-10s\n", $1,$2,$3}'
for img in "${IMAGES[@]}"; do
  docker images $img --format '{{.ID}} {{.Repository}}:{{.Tag}} {{.Size}}' | awk -F' ' '{printf "%-12s %-70s %-10s\n", $1,$2,$3}'
done