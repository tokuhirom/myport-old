url 'http://kernel.org/pub/software/scm/git/git-1.7.3.tar.gz';

sub install {
    run "./configure", '--prefix=' . prefix;
    run 'make';
    run 'make install';
}

