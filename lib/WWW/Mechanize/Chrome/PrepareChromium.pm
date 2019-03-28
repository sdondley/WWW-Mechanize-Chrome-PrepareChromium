package WWW::Mechanize::Chrome::PrepareChromium ;

use strict;
use warnings;
use Proc::ProcessTable;

use Exporter::Easy (
  EXPORT => [ 'prepare_chromium' ],
);

# prepares Chromium for use by WWW::Mechanize::Chrome
sub prepare_chromium {
  my $path_to_chromium = shift || '/Applications/Chromium.app/Contents/MacOS/Chromium';
  my $port             = shift || '9222';

  # $running is set to one of the following: port number, 'running', or 0
  my $running = _get_chromium_status();

  # chromium is running on a debugging port, so we are done
  return $running if ($running =~ /\d\d+/);

  # take appropriate action based on whether chrome is running
  return $running ? _restart ($path_to_chromium, $port)
                  : _start   ($path_to_chromium, $port);
}

# sets the $running variable for prepare_chromium function
sub _get_chromium_status {
  # get the process table
  my $ptable  = Proc::ProcessTable->new;

  # look for Chromium process
  foreach my $pr ( @{$ptable->table} ) {
    if ($pr->fname eq 'Chromium') {
      (my $port) = $pr->cmndline =~ /--remote-debugging-port=(\d+)/;
      return $port || 'running';
    }
  }

  # Chromium not running
  return 0;
}

# start Chromium
sub _start {
  my ($path, $port) = @_;
  my $failed = system "$path --remote-debugging-port=$port &";
  die 'Could not start Chromium. Aborting.' if $failed;
  return $port;
}

# quit Chromium
sub _quit {
  # we call a special bash wrapper function to avoid errors from EyeTv bug
  system ('bash', '-c', q{ source ~/.bash_profile;  osascript -e 'quit app "Chromium"'});
  #system ('/bin/bash', '-ic', q{ osascript -e 'quit app "Chromium"'} );
}

# restart Chromium
sub _restart {
  _quit();
  return _start(@_);
}

# ABSTRACT: prepares Chromium for use by WWW::Mechanize::Chrome
return 1;

__END__

=head1 OVERVIEW

Prepare Chromium for use by L<WWW::Mechanize::Chrome>

=head1 SYNOPSIS

  use WWW::Mechanize::Chrome::PrepareChromium;

  prepare_chromium();

=head1 DESCRIPTION

Ensures a Chromium browser has a remote debugging port available which L<WWW::Mechanize::Chrome>
requires to work.

=func prepare_chromium()

=func prepare_chromium('', $port);

=func prepare_chromium($path_to_chromium);

=func prepare_chromium($path_to_chromium, $port);

Starts or restarts Chrome as necessary with a debugging port. Returns the
debugging port number if already being used or opens a port on the default
port, C<9222>, if Chrome needs to be started.

C<$path_to_chromium> defaults to C</Applications/Chromium.app/Contents/MacOS/Chromium>

C<$port> defaults to C<9222>

=head1 CONFIGURATION AND ENVIRONMENT

WWW::Mechanize::Chrome::PrepareChromium requires a working version of the
Chromium browser.

=head1 DEPENDENCIES

L<Proc::ProcessTable>

=head1 SEE ALSO

L<WWW::Mechanize::Chrome>
