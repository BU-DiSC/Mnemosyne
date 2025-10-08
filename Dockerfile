# This version of Ubuntu uses python3.6
FROM ubuntu:18.04 

RUN apt-get update && apt-get install -y git python3 python3-pip pkg-config build-essential libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev

RUN pip3 install matplotlib==3.0.3

RUN git clone https://github.com/BU-DiSC/Mnemosyne.git
WORKDIR Mnemosyne

# Clone submodules by replacing git with HTTPs to skip authentication
RUN perl -i -p -e 's|git@(.*?):|https://\1/|g' .gitmodules
RUN git submodule sync && git submodule update --init --recursive

CMD ["/Mnemosyne/one-for-all.sh"]
