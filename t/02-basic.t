use Test::Most;
use Test::NoWarnings;
use Log::Log4perl::Shortcuts qw(:all);
BEGIN {
  use Test::File::ShareDir::Module { "WWW::Mechanize::Chrome::PrepareChromium" => "share/" };
  use Test::File::ShareDir::Dist { "WWW-Mechanize-Chrome-PrepareChromium" => "share/" };
}
use WWW::Mechanize::Chrome::PrepareChromium;








my $tests = 1; # keep on line 17 for ,i (increment and ,d (decrement)
plan tests => $tests;
diag( "Running my tests" );

