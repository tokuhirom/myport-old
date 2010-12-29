url 'http://fallabs.com/kyototycoon/pkg/kyototycoon-0.9.19.tar.gz';

sub install {
    run("./configure", "--prefix=" . prefix() );
    run "make";
    run "make install";
}

