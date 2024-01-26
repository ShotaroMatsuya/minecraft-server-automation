FROM --platform=linux/x86_64 amazon/aws-for-fluent-bit@sha256:d1a33dac635f5c1bdaee04a54922bfc38138e3394c0b8d70c6fb73ce669f03aa

ENV TZ='Asia/Tokyo'
COPY fluent-bit_custom.conf /fluent-bit/etc/fluent-bit_custom.conf
COPY inputs.conf /fluent-bit/etc/inputs.conf
COPY stream_processing.conf /fluent-bit/etc/stream_processing.conf
COPY parsers_custom.conf /fluent-bit/etc/parsers_custom.conf
COPY mod_record.lua /fluent-bit/etc/mod_record.lua
COPY add_tag.lua /fluent-bit/etc/add_tag.lua