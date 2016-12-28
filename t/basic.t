use strict;
use warnings;

use JMAP::Tester::Response;
use JSON::Typist;

use Test::Deep;
use Test::Deep::JType;
use Test::More;

# ATTENTION:  You're really not meant to just create Response objects.  They're
# supposed to come from Testers.  Doing that in the tests, though, would
# require mocking up a remote end.  Until we're up for doing that, this is
# simpler for testing. -- rjbs, 2016-12-15

my $typist = JSON::Typist->new;

sub JSTR { $typist->string($_[0]) }
sub JNUM { $typist->number($_[0]) }

subtest "the basic basics" => sub {
  my $res = JMAP::Tester::Response->new({
    _json_typist => $typist,
    struct => [
      [ atePies => { howMany => JNUM(100), tastiestPieId => JSTR(123) }, 'a' ],
      [ platesDiscarded => { notDiscarded => [] }, 'a' ],

      [ drankBeer => { abv => JNUM(0.02) }, 'b' ],

      [ tookNap => { successfulDuration => JNUM(2) }, 'c' ],
      [ dreamed => { about => JSTR("more pie") }, 'c' ],
    ],
  });

  my ($p0, $p1, $p2) = $res->assert_n_paragraphs(3);

  is($p0->sentence(0)->name, "atePies",         "p0 s0 name");
  is($p0->sentence(1)->name, "platesDiscarded", "p0 s1 name");
  is($p1->sentence(0)->name, "drankBeer",       "p1 s0 name");
  is($p2->sentence(0)->name, "tookNap",         "p2 s0 name");
  is($p2->sentence(1)->name, "dreamed",         "p2 s1 name");
};

subtest "old style updated" => sub {
  my %kinds = (
    old => [ 'a', 'b' ],
    new => {
      a => undef,
      b => { awesomeness => JSTR('high') },
    },
  );

  for my $kind (sort keys %kinds) {
    my $res = JMAP::Tester::Response->new({
      _json_typist => $typist,
      struct => [
        [ setPieces => { updated => $kinds{$kind} }, 'a' ]
      ],
    });

    my $s = $res->single_sentence('setPieces')->as_set;

    is_deeply(
      [ sort $s->updated_ids ],
      [ qw(a b) ],
      "we can get updated_ids from $kind style updated",
    );

    my $want = ref $kinds{$kind} eq 'HASH'
             ? $kinds{$kind}
             : { map {; $_ => undef } @{ $kinds{$kind} } };

    is_deeply($s->updated, $want, "can get updated from $kind style updated");
  }
};

done_testing;