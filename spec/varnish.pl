url 'http://www.varnish-software.com/sites/default/files/varnish-2.1.4.tar.gz';

sub install {
    configure;
    make;
    make 'install';
}
