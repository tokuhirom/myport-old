#!/usr/bin/perl
use strict;
use warnings;
use utf8;

url 'http://fallabs.com/kyotocabinet/pkg/kyotocabinet-1.2.30.tar.gz';

sub install {
    run "./configure",  "--prefix=" . prefix;
    run "make";
    run "make install";
}
