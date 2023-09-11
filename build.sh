# usage: ./build.sh <docker iamge name&tag>
image_name=$1
passswd=$2
cat publickey.txt | xargs -0 -I {} docker build -t $image_name --build-arg PublicKey="{}" --build-arg PASSWORD=$2 .