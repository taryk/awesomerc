#!/usr/bin/env perl

use common::sense;

use Mail::IMAPClient;
use HTML::Entities;
use IO::File;
use DateTime;
use Encode qw(decode);

my $home = '/home/taryk';
my $conf = do "$home/.config/awesome/perl/mailchecker.conf";
my %mail;

$,=' ';

my $logger = IO::File->new(">>$conf->{debug_log}")
    or die "Can't open $conf->{debug_log}\n";

sub log_die {
    say $logger '[' . DateTime->now . ']', $$, @_;
    die @_;
}

$SIG{__DIE__} = sub { log_die(@_) };

sub template {
    my $mail_data = shift;

    my $output = sprintf "total_unseen: %s\n", $mail_data->{total_unseen};
    while (my ($email, $details) = each %{ $mail_data->{accounts} }) {
        $output
            .= sprintf "<span weight=\"bold\">%s</span> (%s)\n\n",
            encode_entities($email), $details->{unseen_count};
        next if !$details->{unseen_messages};
        for my $message (@{ $details->{unseen_messages} }) {
            $output
                .= sprintf "<span weight=\"bold\">From</span>: %s, "
                . "<span weight=\"bold\">Subject</span>: %s\n",
                encode_entities(decode('MIME-Header', $message->{From})),
                encode_entities(decode('MIME-Header', $message->{Subject}));
        }
        $output .= "\n";
    }
    return $output;
}

for (@{ $conf->{accounts} }) {
    my ($user, $password) = %$_;

    my $imap = Mail::IMAPClient->new(
        Server   => 'imap.googlemail.com',
        Port     => 993,
        User     => $user,
        Password => $password,
        Ssl      => 1,
        Uid      => 1,
        $conf->{imap_debug}
        ? (
            Debug    => 1,
            Debug_fh => IO::File->new('>>' . $conf->{imap_debug})
                || log_die("Can't open $conf->{imap_debug}:", $!),
          )
        : ()
    ) or log_die('Could not create Mail::IMAPClient instance:', $@);
    $imap->select('Inbox');
    my $unseen_count = $imap->unseen_count('Inbox');
    $mail{accounts}{$user}{unseen_count} = $unseen_count;
    $mail{total_unseen} += $unseen_count;
    if ($unseen_count > 0) {
        my @unseen = $imap->unseen();
        for my $mid (@unseen) {
            my $data = $imap->parse_headers($mid, 'Subject', 'Date', 'From');
            push @{ $mail{accounts}{$user}{unseen_messages} },
                {
                    From    => $data->{From}[0],
                    Subject => $data->{Subject}[0],
                    Date    => $data->{Date}[0],
                };
        }
    }
    $imap->close  or log_die('Could not close:', $imap->LastError);
    $imap->logout or log_die('Logout error:',    $imap->LastError);
}

my $output_file = IO::File->new(">$conf->{output_file}");
print $output_file template(\%mail);

$output_file->close()
    or log_die("Could not close $conf->{output_file}:", $!);

END { $logger->close() or log_die("Could not close $conf->{debug_log}:", $!) }
