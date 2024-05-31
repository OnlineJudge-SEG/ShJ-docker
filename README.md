## ShJ-docker
This repository contains scripts and DockerFile for building customized sharif-judge docker image.
Customizing sharif-judge is achieved by applying `patch.diff` to [maurostorch/Sharif-judge](https://github.com/maurostorch/Sharif-Judge), on branch Version-1.
You can make a fork of that repository and make any customizations as you want, then generate the diff file and replace `patch.dff` with it to satisfy your needs. A customized docker image will automatically be generated.
Apart from customizing sharif-judge, the scripts in Dockerfile also make the following changes, for more up-to-date environments and easier-to-use configuration:
- upgrade C/C++ compiler form GCC(G++) 4.8 to GCC(G++) 9.4.0
- upgrade java environments to openjdk version "17-ea"
- upgrade python3 from 3.4 to 3.9.0
- change the password of `root` user of mysql, which is used for database access in sharif judge
- change the defualt settings of sharif judge to proper value
- setup download directory for directly downloading operation manuals for students through [http://ip:port/docs/manual.pdf](http://ip:port/docs/manual.pdf)
- (optional) automatically install openssh server and setup passwordless remote access through ssh. 


### How to run
Simply type the following command:
```bash
./build.sh <image:tag> <password>
```
The docker image will be built properly with name `<image:tag>`, `<password>` is used for mysql access.

The whole process will take around 24 minutes.

### SSH access
If you want to ssh your container for debugging purpose, you cound uncomment the corresponding lines in `Dockerfile` and `start.sh`.
Also, you could put your public key into `publickey.txt`, then it would be used in configuring passwordless remote access automatically.