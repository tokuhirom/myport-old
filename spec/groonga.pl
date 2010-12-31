url 'http://groonga.org/files/groonga/groonga-1.0.5.tar.gz';

sub install {
    configure;
    make;
    make 'install';
}

