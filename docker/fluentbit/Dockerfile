FROM --platform=linux/x86_64 amazon/aws-for-fluent-bit@sha256:dc4b4fb36e9c3eb6246aefa09b15d2890ec941e0741c964e78a99f7ff4428b4d

ENV TZ='Asia/Tokyo'
COPY fluent-bit_custom.conf /fluent-bit/etc/fluent-bit_custom.conf
COPY inputs.conf /fluent-bit/etc/inputs.conf
COPY stream_processing.conf /fluent-bit/etc/stream_processing.conf
COPY parsers_custom.conf /fluent-bit/etc/parsers_custom.conf
COPY mod_record.lua /fluent-bit/etc/mod_record.lua
COPY add_tag.lua /fluent-bit/etc/add_tag.lua