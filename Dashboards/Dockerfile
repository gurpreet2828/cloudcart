FROM python:3.11

LABEL maintainer="Container Solutions <info@container-solutions.com>"

RUN apt-get update && apt-get install -y curl git parallel \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /root/.parallel \
 && touch /root/.parallel/will-cite

RUN pip install --no-cache-dir git+https://github.com/weaveworks/grafanalib@82556ddfbbd6134837d280a7999d35c45cc3c87e

RUN sed -i 's/convert=/converter=/g' /usr/local/lib/python3.11/site-packages/grafanalib/core.py

WORKDIR /opt/code

CMD ["/bin/bash"]
