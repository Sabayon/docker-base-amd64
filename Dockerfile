FROM sabayon/stage3-amd64

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Cleanup and applying configs
ADD ./script/post-update.sh /post-update.sh
RUN /bin/bash /post-update.sh && rm -rf /post-update.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]
