# syntax=docker/dockerfile:1-labs

FROM ubuntu

COPY ./install_deps.sh .
COPY ./start.sh .

RUN chmod u+x ./install_deps.sh
RUN chmod u+x ./start.sh

RUN /install_deps.sh

RUN git clone https://github.com/aptos-labs/aptos-core.git --depth 1

ENV PATH=/root/.local/bin:$PATH

WORKDIR aptos-core/testsuite

RUN poetry install

CMD /start.sh
