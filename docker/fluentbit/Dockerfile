FROM --platform=linux/x86_64 amazon/aws-for-fluent-bit@sha256:f89e4ab5ef51eead950717b99932414ffb1ca01aeb18084ec4314f9c32382b64

ENV TZ='Asia/Tokyo'
COPY fluent-bit_custom.conf /fluent-bit/etc/fluent-bit_custom.conf
COPY inputs.conf /fluent-bit/etc/inputs.conf
COPY stream_processing.conf /fluent-bit/etc/stream_processing.conf
COPY parsers_custom.conf /fluent-bit/etc/parsers_custom.conf
COPY mod_record.lua /fluent-bit/etc/mod_record.lua
COPY add_tag.lua /fluent-bit/etc/add_tag.lua