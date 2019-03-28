#/usr/bin/env perl
use Test::More;
use Test::Exception;
use WWW::Mechanize::Chrome::PrepareChromium;
use Proc::ProcessTable;
use Log::Log4perl::Shortcuts qw(:all);











my $tests = 4; # keep on line 17 for ,i (increment and ,d (decrement)
plan tests => $tests;
diag( "Running tests" );


my $ch = '/Applications/Chromium.app/Contents/MacOS/Chromium';
my $port = '9222';

# make sure Chromium is closed
my $running;
lives_ok { $running = &WWW::Mechanize::Chrome::PrepareChromium::_get_chromium_status } 'gets browser status';
quit() if $running;

start();
sleep(2);
my $pid = get_pid();
die 'Could not find Chromium process' if !$pid;

my $browser_port = prepare_chromium();
is ($browser_port, 9222, 'starts browser on port 9222');
sleep(2);
my $new_pid = get_pid();
isnt ($pid, $new_pid, 'new browser instance is running');

prepare_chromium();
sleep(2);
my $newest_pid = get_pid();
is $new_pid, $newest_pid, 'same browser still running';

quit();


sub quit {
  WWW::Mechanize::Chrome::PrepareChromium::_quit();
}

sub start {
  my $with_debugging = shift;
  if ($with_debugging) {
    prepare_chromium();
  } else {
    my $failed = system "open $ch &";
  }
}

sub restart {
  WWW::Mechanize::Chrome::PrepareChromium::_start();
}

sub get_pid {
  my $ptable  = Proc::ProcessTable->new;

  foreach my $pr ( @{$ptable->table} ) {
    if ($pr->fname =~ /Chromium/) {
      return $pr->pid;
    }
  }
}
