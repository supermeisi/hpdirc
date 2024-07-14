sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
sudo docker buildx create --name mybuilder --use
sudo docker buildx inspect --bootstrap
sudo docker image build . -t supermeisi/hpdirc
sudp docker buildx build --platform linux/amd64,linux/arm64 -t supermeisi/hpdirc --push .
