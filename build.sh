docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap
docker image build . -t supermeisi/hpdirc
docker buildx build --platform linux/amd64,linux/arm64 -t supermeisi/hpdirc --push .
