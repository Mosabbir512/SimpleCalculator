# Ubuntu-based Java ইমেজ ব্যবহার করুন
FROM ubuntu:22.04

# Non-interactive mode সেট করুন
ENV DEBIAN_FRONTEND=noninteractive

# Java এবং প্রয়োজনীয় প্যাকেজ ইনস্টল করুন
RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxext6 \
    libx11-6 \
    libxcb1 \
    libxau6 \
    libxdmcp6 \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# কাজের ডিরেক্টরি সেট করুন
WORKDIR /app

# আপনার Java ফাইল কপি করুন
COPY SimpleCalculator.java /app/

# Java ফাইল কম্পাইল করুন
RUN javac SimpleCalculator.java

# স্টার্টআপ স্ক্রিপ্ট তৈরি করুন
RUN echo '#!/bin/bash\n\
# ভার্চুয়াল ডিসপ্লে শুরু করুন\n\
Xvfb :99 -screen 0 1024x768x24 &\n\
sleep 3\n\
\n\
# VNC সার্ভার শুরু করুন\n\
x11vnc -display :99 -forever -nopw -shared &\n\
sleep 2\n\
\n\
# noVNC শুরু করুন\n\
websockify --web /usr/share/novnc 8080 localhost:5900 &\n\
sleep 2\n\
\n\
# ক্যালকুলেটর চালু করুন\n\
export DISPLAY=:99\n\
java SimpleCalculator\n\
' > /app/start.sh && chmod +x /app/start.sh

# পোর্ট খুলুন
EXPOSE 8080

# অ্যাপ চালানোর কমান্ড
CMD ["/app/start.sh"]