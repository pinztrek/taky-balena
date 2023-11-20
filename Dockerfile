# First stage: builder
FROM python:3.11 as builder

ENV TAKY_VERSION=0.9

# UTC because everything on a server should be UTC
#RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtim


RUN apt-get update &&\
    apt-get -y upgrade &&\
    apt-get -y install libxml2-dev libxslt-dev libcairo2-dev rustc


WORKDIR /build

#RUN git clone --depth 1 https://github.com/tkuester/taky.git -b ${TAKY_VERSION}

#WORKDIR /build/taky

RUN python3 -m pip install --upgrade pip && \
    pip3 install taky &&\
    #python3 -m pip install -r requirements.txt && \
    #python3 setup.py install && \
    find /usr/local -name '*.pyc' -delete && \
    find /usr/local -name '__pycache__' -type d -exec rm -rf {} +

# Second stage: runtime
FROM python:3.11-slim as runtime

WORKDIR /

#Setup user
RUN addgroup --gid 1000 tak  &&\
    adduser --gecos "" --disabled-password --uid 1000 --ingroup tak --home /home/tak tak 

RUN echo "set -o vi \nalias ll='ls -l'\nexport VISUAL=vim;export EDITOR=$VISUAL" \
    >> /etc/bash.bashrc


RUN apt-get update &&\
    apt-get -y upgrade &&\
    apt-get -y install libxml2-dev libxslt-dev libcairo2-dev vim wget curl procps

# copy over executables
COPY --from=builder /usr/local /usr/local
COPY start-tak*.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/start-tak*.sh 

# Copy a config if it exists. Need an empty dir normally even if no config
# Problem is only works if cfg files are checked into git
#COPY --chown=1000:1000 ./taky /tmp/taky


# should never use this, override via docker_compose
#ENTRYPOINT [ "taky", "-c", "/data/taky/taky.conf" ]
ENTRYPOINT [ "taky", "--version" ]
