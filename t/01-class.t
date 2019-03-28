#/usr/bin/env perl
use Test::More;
use Test::Exception;
use WWW::Mechanize::Chrome::PrepareChromium;
use Proc::ProcessTable;
use Log::Log4perl::Shortcuts qw(:all);










my $tests = 4; # keep on line 17 for custom vim shortcuts: ,i (increment and ,d (decrement)
plan tests => $tests;
diag( "Running tests" );


my $ch = '/Applications/Chromium.app/Contents/MacOS/Chromium';
my $port = '9222';

# make sure Chromium is closed
my $running;
lives_ok { $running = &WWW::Mechanize::Chrome::PrepareChromium::_get_chromium_status } 'gets browser status';
quit() if $running;

# start without debugging enabled
start();

sleep(2); # we need to sleep because process table isn't updated immediately
my $pid = get_pid();
die 'Could not find Chromium process' if !$pid;

# should quit browser and reopen with port debugging
my $browser_port = prepare_chromium();
is ($browser_port, 9222, 'return port number');
sleep(2); # wait for process table to update
my $new_pid = get_pid();
isnt ($pid, $new_pid, 'new browser instance is running');

prepare_chromium(); # should not open new browser instance
sleep(2); # wait for process table to update
my $newest_pid = get_pid();
is $new_pid, $newest_pid, 'same browser still running';

quit();


sub quit {
  WWW::Mechanize::Chrome::PrepareChromium::_quit();
}

sub start {
  my $failed = system "open $ch &";
}

sub get_pid {
  my $ptable  = Proc::ProcessTable->new;

  foreach my $pr ( @{$ptable->table} ) {
    if ($pr->fname =~ /Chromium/) {
      return $pr->pid;
    }
  }
}
