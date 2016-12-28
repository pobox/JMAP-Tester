package JMAP::Tester::Logger;

use Moo::Role;

use JMAP::Tester::LogWriter;
use Params::Util qw(_CODELIKE _HANDLE _SCALAR0);

has writer => (
  is  => 'ro',
  isa => sub {
    die "no writer provided" unless $_[0];
    die "writer provided can't be called as code" unless $_[0]->does('JMAP::Tester::LogWriter');
  },
  coerce   => sub {
    my $value = $_[0];
    return JMAP::Tester::LogWriter::Code->new({ code => $value })
      if _CODELIKE($value);

    return JMAP::Tester::LogWriter::Handle->new({ handle => $value })
      if _HANDLE($value);

    return JMAP::Tester::LogWriter::Code->new({ code => sub{} })
      if _SCALAR0($value) && ! defined $$value;

    return JMAP::Tester::LogWriter::Filename->new({ filename_template => $value })
      if defined $value && ! ref $value && length $value;

    return $value;
  },
  required => 1,
);

sub write {
  my ($self, $string) = @_;
  $self->writer->write( $string );
}

requires 'log_jmap_request';
requires 'log_jmap_response';

requires 'log_upload_request';
requires 'log_upload_response';

requires 'log_download_request';
requires 'log_download_response';

1;
