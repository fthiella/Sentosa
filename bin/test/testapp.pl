#!/usr/bin/env perl

use Poet::Script qw($conf $poet $dbh);
use Sentosa::Utils;
use Sentosa::Users;
use Data::Dumper;

print <<BANNER;
# Sentosa Autoform test app

BANNER

print "Portal name =====> ", Sentosa::Utils::get_info('name'), "\n";
print "Portal version ==> ", Sentosa::Utils::get_info('version'), "\n";
print "\n";

print "Database driver => ", $dbh->{Driver}{Name}, "\n";
print "\n";

print "Default admin password =====> ", Sentosa::Users::auth_user('admin', 'password') ? "Yes": "No", "\n";
print "\n";

my $u = 1;
print "## USER 1\n";
print "\n";

my $h = Sentosa::Users::get_userinfo($u); # TODO: why hash reference?
print "User info ============> (", (join ', ', map { $_ . '=' . $h->{$_} } keys %{$h}), ")\n";
print "User property (code) => ", Sentosa::Users::get_userproperty($u, 'code'), "\n";

foreach $g (Sentosa::Users::get_groupsuserinfo($u)) {
	print (join ', ', map { $_ . '=' . $g->{$_} } keys %{$g}), "\n";
}
