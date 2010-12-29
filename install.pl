#!/usr/bin/perl
use strict;
use autodie;
use Carp ();
use File::Path;
use File::stat;
use LWP::UserAgent;
use File::Basename;

if (@ARGV == 0) {
    die "Usage: install.pl pkgname";
}

my $pkgname = shift @ARGV;

my $base_prefix = "/usr/local/app/";
unless (-d $base_prefix) {
    mkdir $base_prefix;
}

unless (-f "spec/$pkgname.pl") {
    die "missing spec/$pkgname.pl";
}

my $src = do {
    open my $fh, '<', "spec/$pkgname.pl";
    local $/;
    <$fh>;
};
$src = qq{use strict;\nuse autodie;\n#line 1 "spec/$pkgname.pl"\n$src;1;};

my $mtime = stat("spec/$pkgname.pl")->mtime;
mkpath("build/$pkgname-$mtime/");
chdir("build/$pkgname-$mtime/");

my $URL;
eval($src) or die $@;
get($URL);
extract();
install();
activate();
exit 0;

my $TARBALL;

sub pkg_name_version {
    $TARBALL or die "missing tar ball path";
    (my $dir = $TARBALL) =~ s/\.(tar|gz|tgz|tbz|bz|bz2|zip|lzh)//g;
    $dir;
}

sub version {
    (my $ver = pkg_name_version()) =~ s/^$pkgname-?//;
    $ver;
}

sub prefix () {
    my $prefix = File::Spec->catdir($base_prefix, pkg_name_version());
    infof("prefix directory is $prefix");
    return $prefix;
}

sub infof {
    print "[INFO] @_\n";
}

sub run {
    infof("run: @_");
    system(@_) == 0 or Carp::croak("\n\nFAILED to run: @_");
}

sub url {
    $URL = shift;
}

sub get {
    my $url = shift or die "missing url";
    (my $dst = $url) =~ s!.+/!!;
    if (-f $dst) {
        infof("$dst is already exists");
    } else {
        infof("fetching $dst from $url");
        my $ua = LWP::UserAgent->new(agent => "myport");
        $ua->mirror($url, $dst) or die;
    }
    $TARBALL = $dst;
}

sub extract {
    infof("extract $TARBALL");
    system "tar xvf $TARBALL";

    opendir my $d, ".";
    while (readdir $d) {
        next if /^\./;
        if (-d $_) {
            infof("chdir to $_");
            chdir $_;
            return;
        }
    }
    closedir $d;
}

sub activate {
    unlink("$base_prefix/$pkgname") if -e "$base_prefix/$pkgname";

    # ln -s $PREFIX/$APP-$VERSION $PREFIX/$APP
   symlink prefix(), "$base_prefix/$pkgname";

    for my $dir (qw/lib bin include/) {
        if (-d "$base_prefix/$pkgname/$dir") {
            for (<$base_prefix/$pkgname/$dir/*>) {
                my $basename = basename($_);
                my $dst = "/usr/local/$dir/$basename";
                if (-e $dst) {
                    infof("skip link $_ to $dst, since it is already exists.");
                } else {
                    run "sudo ln -s $_ $dst";
                }
            }
        }
    }

    run "sudo /sbin/ldconfig";
}

__END__
function install_autotools () {
    if [ ! -f $TARFILE ]; then
        wget $SRCURL
    fi

    tar xzvf $TARFILE
    cd $TARDIR
    ./configure --prefix=/usr/local/app/$APP-$VERSION $CONFIGURE_OPTS
    make
    make install
}

