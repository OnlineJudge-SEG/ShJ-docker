FROM maurostorch/sharif-judge:latest

ARG PublicKey
ARG PASSWORD

# redefine the startup command
COPY --chown=root:root start.sh /start.sh
# for update sharif-judge to customized version
COPY --chown=www-data:www-data patch.diff /var/www/html/

# apply git patch to update sharif-judge
# config directory for tester and assignments
# change password for mysql
RUN cd /var/www/html && \
    git checkout -- . && \
    git apply patch.diff && \
    chown -R www-data:www-data /var/www/html && \
    mkdir /data && \
    mv /var/www/html/tester /data/ && \
    mv /var/www/html/assignments /data/ && \
    sed -i "s/'password' => '1q2w3e4r'/'password' => '"${PASSWORD}"'/g" /var/www/html/application/config/database.php && \
    echo "mysqladmin -uroot -p1q2w3e4r password "${PASSWORD}"\n" >> /start.sh && \
    echo "/bin/bash" >> /start.sh


# install compile environment for c/c++/java
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive && \
    apt-get install software-properties-common -y && \
    apt-get install --reinstall ca-certificates -y && \
    echo "\n" | add-apt-repository ppa:ubuntu-toolchain-r/test && \
    echo "\n" | add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install gcc-9 g++-9 openjdk-17-jdk-headless openjdk-17-jre-headless -y && \
    ln -s -f /usr/bin/gcc-9 /usr/bin/gcc && \
    ln -s -f /usr/bin/g++-9 /usr/bin/g++

# install openssh-server: enable remote-access for debugging and maintaining
RUN apt-get install openssh-server -y && \
    mkdir /root/.ssh/ && chmod 700 /root/.ssh && \
    echo "${PublicKey}" > /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys


CMD ["/bin/bash", "/start.sh"]

# for apache2
EXPOSE 80
# for ssh
EXPOSE 22