# Adapted from https://medium.com/@pierreprinetti/the-go-1-11-dockerfile-a3218319d191

# Accept the Go version for the image to be set as a build argument.
# Default to 1.21 Go version
ARG GO_VERSION=1.21

ARG REGISTRY="docker.io/library"
# First stage: build the executable.
# NOTE: alpine is smaller than stretch, which is debian-based, but does not
# include libc, which is necessary for the go race detector. Since it is
# useful to be able to run unit tests with the race flag in a container built
# from this builder image, we use the debian version instead of alpine
FROM ${REGISTRY}/golang:${GO_VERSION} AS builder

# Create the user and group files that will be used in the running container to
# run the process as an unprivileged user.
RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group

# Install the Certificate-Authority certificates for the app to be able to make
# calls to HTTPS endpoints.
# NOTE: This was necessary with the alpine image, but does not seem to be
# necessary with the debian image
# RUN apk add --no-cache ca-certificates

# Set the working directory outside $GOPATH to enable the support for modules.
WORKDIR /src

# Warm the build cache with a non-cgo (i.e. static) standard library build
# (a go.mod file must exist or it will not run in module-aware mode, and will
# therefore not warm the cache)
RUN go mod init temp 2>&1
RUN CGO_ENABLED=0 go build -installsuffix 'static' std

# Import the code from the context.
COPY ./ ./

# Set the environment variables for the go command:
# * GOFLAGS=-mod=vendor to force `go build` to look into the `/vendor` folder.
ENV GOFLAGS=-mod=vendor

# Build the executable to `/gosnowflake-example`. Mark the build as statically linked.
RUN CGO_ENABLED=0 go build \
    -installsuffix 'static' \
    -o /gosnowflake-example ./

# Final stage: the running container.
FROM scratch AS final

# Import the user and group files from the first stage.
COPY --from=builder /user/group /user/passwd /etc/

# Import the Certificate-Authority certificates for enabling HTTPS.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the compiled executable from the second stage.
COPY --from=builder /gosnowflake-example /gosnowflake-example

# Perform any further action as an unprivileged user.
USER nobody:nobody

# Run the compiled binary.
ENTRYPOINT ["/gosnowflake-example"]