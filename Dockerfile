FROM maurostorch/sharif-judge:latest

ARG PASSWORD

# redefine the startup command
COPY --chown=root:root start.sh /start.sh
# for update sharif-judge to customized version
COPY --chown=www-data:www-data patch.diff /var/www/html/

# apply git patch to update sharif-judge
# config directory for tester and assignments
# change password for mysql for the first time the container start
RUN cd /var/www/html && \
    git checkout -- . && \
    git apply patch.diff && \
    chown -R www-data:www-data /var/www/html && \
    mkdir /data && \
    mv /var/www/html/tester /data/ && \
    mv /var/www/html/assignments /data/ && \
    sed -i "s/'username' => ''/'username' => 'root'/g" /var/www/html/application/config/database.php && \
    sed -i "s/'password' => ''/'password' => '"${PASSWORD}"'/g" /var/www/html/application/config/database.php && \
    sed -i "s/'database' => ''/'database' => 'sharif'/g" /var/www/html/application/config/database.php && \
    echo "mysqladmin -uroot -p1q2w3e4r password "${PASSWORD}"" >> /start.sh && \
    echo "head -n -4 /start.sh > tmp && mv tmp /start.sh && echo '/bin/bash' >> /start.sh" >> /start.sh && \
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

# upgrade python version
RUN apt-get install -y build-essential libssl-dev zlib1g-dev \
    libncurses5-dev libgdbm-dev libnss3-dev libreadline-dev \
    libffi-dev wget curl && \
    cd /usr/src && wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz && \
    tar xzf Python-3.9.0.tgz && \
    cd Python-3.9.0 && ./configure --enable-optimizations && make altinstall && \
    rm /usr/bin/g++ && ln -s /usr/bin/g++-9 /usr/bin/g++ && \
    rm /usr/bin/python3 && ln -s /usr/local/bin/python3.9 /usr/bin/python3

# copy manual for students to download directory
COPY --chown=wwww-data:www-data doc /var/www/html/docs
RUN chown -R www-data /var/www/html/docs

# install openssh-server: enable remote-access for debugging and maintaining
# NOTE: uncomment the following command if you want to ssh you container
# ARG PublicKey
# RUN apt-get install openssh-server -y && \
#     mkdir /root/.ssh/ && chmod 700 /root/.ssh && \
#     echo "${PublicKey}" > /root/.ssh/authorized_keys && \
#     chmod 600 /root/.ssh/authorized_keys
# EXPOSE 22

CMD ["/bin/bash", "/start.sh"]

# for apache2
EXPOSE 80