FROM postgres:12.5-alpine
ENV POSTGRES_HOST_AUTH_METHOD=trust
COPY . /databases/
WORKDIR /databases/
RUN dos2unix *.sh && \
    chmod +x *.sh
