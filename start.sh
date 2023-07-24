#!/bin/sh

bin/simple_ms_blocklist eval "TestKonsi.Release.migrate" && \
bin/simple_ms_blocklist eval "TestKonsi.Release.seed" && \
bin/simple_ms_blocklist start
