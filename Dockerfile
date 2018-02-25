FROM golang:1.9

RUN apt-get update \
    && apt-get install -y \
    build-essential \
    cmake \
    git \
    unzip \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-22-dev \
    && mkdir -p /opt/opencv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/opencv

ENV OPENCV_VERSION 3.4.0
ENV OPENCV_CONTRIB_VERSION 3.4.0

RUN wget --no-check-certificate -q -O opencv.zip \
    https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
    && unzip opencv.zip \
    && wget --no-check-certificate -q -O opencv_contrib.zip \
    https://github.com/opencv/opencv_contrib/archive/${OPENCV_CONTRIB_VERSION}.zip \
    && unzip opencv_contrib.zip \
    && rm -rf opencv-${OPENCV_VERSION}.zip ${OPENCV_CONTRIB_VERSION}.zip

RUN mkdir -p /opt/opencv/opencv-${OPENCV_VERSION}/build \
    && (cd /opt/opencv/opencv-${OPENCV_VERSION}/build \
    && cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv/opencv_contrib-${OPENCV_CONTRIB_VERSION}/modules \
    -D BUILD_DOCS=OFF BUILD_EXAMPLES=OFF \
    -D WITH_GTK=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_opencv_java=OFF \
    -D BUILD_opencv_python=OFF \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=OFF .. \
    && make -j4 \
    && make install) \
    && ldconfig \
    && rm -rf /opt/opencv

RUN go get -u -d gocv.io/x/gocv

WORKDIR /go/src/gocv.io/x/gocv

RUN /bin/bash -c "source ./env.sh \
    && go run ./cmd/version/main.go"
