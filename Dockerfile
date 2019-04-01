FROM nixos/nix AS nixos-base
# Install depends
RUN nix-env -iA nixpkgs.git nixpkgs.curl

ADD ./assets/etc/nix/nix.conf /etc/nix/nix.conf

# Output image(s)
FROM nixos-base
EXPOSE 8000/tcp
EXPOSE 8100/tcp
EXPOSE 8110/tcp
HEALTHCHECK CMD curl -f http://localhost:8100/api/blocks/pages/total || exit 1
WORKDIR /opt
ADD ./assets /assets
ENTRYPOINT ["/assets/bin/entrypoint"]

# Build args
ARG BUILD_TIMESTAMP=201904011200
ARG CARDANO_NET=mainnet
ARG CARDANO_SL_GIT_COMMIT=develop
# Default environment
ENV BUILD_TIMESTAMP ${BUILD_TIMESTAMP}
ENV LISTEN_ADDR 127.0.0.1:8000
ENV CARDANO_SL_GIT_COMMIT ${CARDANO_SL_GIT_COMMIT}

RUN git clone https://github.com/input-output-hk/cardano-sl.git && \
    cd cardano-sl && \
    git checkout ${CARDANO_SL_GIT_COMMIT}
WORKDIR /opt/cardano-sl
VOLUME ["/opt/cardano-sl/state-explorer-${CARDANO_NET}/logs"]

# Setup cardano-sl
ENV CARDANO_NET ${CARDANO_NET}
RUN nix-build -A connectScripts.${CARDANO_NET}.explorer -o connect-explorer-to-${CARDANO_NET}
