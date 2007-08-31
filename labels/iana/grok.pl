#!/usr/bin/perl

my %M = qw (Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 8 Oct 10 Nov 11 Dec 12);

# input is http://www.iana.org/ipaddress/ip-addresses.htm
# output is the same info, but in a better format

use strict;
use warnings;
use Net::CIDR::Lite;

# if $when is specified, then blocks assigned after $when
# will be changed to "IANA - Reserved".  Format of $when
# is YYYYMMDD -- ugh.
#
my $when = shift;

my $cidr = Net::CIDR::Lite->new;
my $last_desc = undef;

while (<>) {
        chomp;
	next unless (/^(\d\d\d)\/8\s+(\w\w\w) (\d\d)\s+(.*)/);
	my $block = $1;
	my $month = $2;
	my $year = $3;
	my $desc = $4;

	$year += $year < 70 ? 2000 : 1900;

	my $sdate = $year * 10000 + $M{$month} * 100;

	# Clean up descriptions
	$desc =~ s/\s+$//g;
	$desc =~ s/\s+\(.*\)$//;
	$desc =~ s/\s+See \[.*$//;
	$desc =~ s/IANA - Multicast/Multicast/;
	$desc =~ s/ARIN - Cable Block/Cable/;
	$desc =~ s/IANA - Reserved/Reserved/;
	$desc =~ s/RIPE NCC/RIPE/;
	$desc =~ s/Level 3 Communications, Inc\./Level3/;
	$desc =~ s/General Electric Company/GE/;
	$desc =~ s/Army Information Systems Center/US Army/;
	$desc =~ s/IANA - Private Use/RFC1918/;
	$desc =~ s/AT\&T Bell Laboratories/AT\&T/;
	$desc =~ s/Xerox Corporation/Xerox/;
	$desc =~ s/Hewlett-Packard Company/HP/;
	$desc =~ s/Digital Equipment Corporation/DEC/;
	$desc =~ s/Apple Computer Inc\./Apple/;
	$desc =~ s/Defense Information Systems Agency/DISA/;
	$desc =~ s/AT\&T Global Network Services/AT\&T/;
	$desc =~ s/Halliburton Company/Halliburton/;
	$desc =~ s/MERIT Computer Network/Merit/;
	$desc =~ s/Performance Systems International/PSI/;
	$desc =~ s/Eli Lily and Company/Eli Lily/;
	$desc =~ s/Interop Show Network/Interop/;
	$desc =~ s/Prudential Securities Inc\./Prudential/;
	$desc =~ s/DoD Network Information Center/DoD NIC/;
	$desc =~ s/U\.S\. Postal Service/USPS/;

	$desc = 'Reserved' if ($when && $sdate > $when);

	my $prefix = sprintf "%d.0.0.0/8", $block;
	if ($last_desc && $desc ne $last_desc) {
		foreach $prefix ($cidr->list) {
			printf "%s\t%s\n", $prefix, $last_desc;
		}
		$cidr = undef;
		$cidr = Net::CIDR::Lite->new;
		$last_desc = undef;
	}
	$cidr->add($prefix);
	$last_desc = $desc;
}
		foreach my $prefix ($cidr->list) {
			printf "%s\t%s\n", $prefix, $last_desc;
		}