#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Carp;
#use Sys::Syslog qw(:DEFAULT setlogsock);
use Storable qw/lock_nstore lock_retrieve/;
use File::Find;
use File::Path;
use Encode qw/encode decode/;
use LWP::Simple qw/get/;
use XML::Simple; #sudo yum install  expat-devel perl-XML-Simple
use Data::Dumper;
use DBI;
use DBD::Pg;
use DBD::SQLite;

# PostgreSQL
#my $DSN="dbi:Pg:dbname=foltia;host=localhost;port=5432";
my $DSN="dbi:SQLite:syobocal.sqlite";
my $DBUser="foltia";
my $DBPass="foltiaadmin";
my $dbh;
  my $DBCreate =  <<"SQL";
CREATE TABLE
  syobocal_program
    (tid bigint not null
    , title text
    , cat text
    , firstyear text
    , firstmonth text
    , firstendyear text
    , firstendmonth text
    , userpoint text
    , userpointRank text
    , titleyomi text
    , primary key (tid)
);
SQL

  my $DBInsert1 =  <<"SQL";

INSERT INTO
  syobocal_program
    (tid
    , title
    , cat
    , userpoint
    , userpointRank) VALUES (?,?,?,?,?)
SQL

  my $DBDelete1 =  <<"SQL";

DELETE FROM
  syobocal_program
WHERE
  tid = ?
SQL

  my $DBInsert2 =  <<"SQL";
UPDATE syobocal_program 
SET
  titleyomi = ?
WHERE
  tid = ?
SQL

  my $DBInsert4 =  <<"SQL";
UPDATE syobocal_program 
SET
  firstyear = ?,
  firstmonth = ?
WHERE
  tid = ?
SQL

  my $DBInsert3 =  <<"SQL";
UPDATE syobocal_program 
SET
  firstendyear = ?,
  firstendmonth = ?
WHERE
  tid = ?
SQL

  my $DBQuery =  <<"SQL";
  SELECT title
    , cat
    , firstyear
    , firstmonth
    , firstendyear
    , firstendmonth
    , userpoint
    , userpointRank
    , titleyomi 
  FROM   syobocal_program
  WHERE
    tid = ?
SQL

  my $DBQueryAll =  <<"SQL";
  SELECT
    tid
    , title 
  FROM
    syobocal_program
SQL


#setlogsock 'unix';
#openlog($0, 'pid', 'local0');
my $regex = '\.(m2t|MP4|aac)$';
my $dept = '/record/';
my $nomakedir = 0;
my $tv = '/home/foltia/php/tv/';
my $tiddb = 'tid.db';
my %tidarc = ();
my $tid = \%tidarc;
#my %cat = qw#
#    1   アニメ
#    10  アニメ完了
#    7   OVA
#    5   アニメ関連
#    4   特撮
#    8   映画
#    3   テレビ
#    2   ラジオ
#    6   メモ
#    0   その他
##;
my %cat = qw#
    1   アニメ
    10  アニメ
    7   アニメ
    5   アニメ
    4   特撮
    8   アニメ
    3   アニメ
    2   ラジオ
    6   アニメ
    0   その他
#;

$tid->{0}->{title} = 'unknown';
$tid->{0}->{cat} = 0;
sub tid_to_name
{
  my $number = shift;
  my $title;
  my $cat;
  my $sth;
  return unless($number); #number=0 => TIDの指定が不正です
  #PG>
  $sth = $dbh->prepare($DBQuery);
  $sth->execute($number);
  ($tid->{$number}->{title},
    $tid->{$number}->{cat},
    $tid->{$number}->{FirstYear},
    $tid->{$number}->{FirstMonth},
    $tid->{$number}->{FirstEndYear},
    $tid->{$number}->{FirstEndMonth},
    $tid->{$number}->{UserPoint},
    $tid->{$number}->{UserPointRank},
    $tid->{$number}->{TitleYomi}) = $sth->fetchrow_array;
  $sth->finish;

  return if(defined($tid->{$number}->{title}));
  #<PG
 # sleep 1;
  my $config = XMLin(get(sprintf 
    qq|http://cal.syoboi.jp/db.php?Command=TitleLookup&TID=%d|,
     $number));
	$title = $config->{TitleItems}->{TitleItem}->{Title};
	# リネームできんかった
	$title =~ s/\//／/g if($title);
	$title =~ s/\:/：/g if($title);
	$title =~ s/\*/＊/g if($title);
	$title =~ s/\?/？/g if($title);
	$title =~ s/\"/”/g if($title);
	$title =~ s/\</＜/g if($title);
	$title =~ s/\>/＞/g if($title);
	$title =~ s/\|/｜/g if($title);
	$title =~ s/\"/”/g if($title);
	$title =~ s/\!/！/g if($title);
	$title =~ s/\\/＼/g if($title);
	$title =~ s/♡/_/g  if($title);
	# local
	$tid->{$number}->{title} = $title;
	$tid->{$number}->{cat} = $config->{TitleItems}->{TitleItem}->{Cat};
	$tid->{$number}->{FirstYear} = $config->{TitleItems}->{TitleItem}->{FirstYear};
	$tid->{$number}->{FirstMonth} = $config->{TitleItems}->{TitleItem}->{FirstMonth};
	$tid->{$number}->{FirstEndYear} = $config->{TitleItems}->{TitleItem}->{FirstEndYear};
	$tid->{$number}->{FirstEndMonth} = $config->{TitleItems}->{TitleItem}->{FirstEndMonth};
	$tid->{$number}->{UserPoint} = $config->{TitleItems}->{TitleItem}->{UserPoint};
	$tid->{$number}->{UserPointRank} = $config->{TitleItems}->{TitleItem}->{UserPointRank};
	$tid->{$number}->{TitleYomi} = $config->{TitleItems}->{TitleItem}->{TitleYomi};
	#PG>
	$tid->{$number}->{title} = encode('utf-8', $tid->{$number}->{title});
	$tid->{$number}->{TitleYomi} = encode('utf-8', $tid->{$number}->{TitleYomi});
	$sth = $dbh->prepare($DBInsert1);
 	eval { $sth->execute($number,
			$tid->{$number}->{title},
			$tid->{$number}->{cat},
			$tid->{$number}->{UserPoint},
			$tid->{$number}->{UserPointRank},
		); };
	if ($@) {
	$sth = $dbh->prepare($DBDelete1);
		eval { $sth->execute($number);};
	}	
	$sth->finish;

	$sth = $dbh->prepare($DBInsert2);
	eval { $sth->execute(
			$tid->{$number}->{TitleYomi},
			$number
		);};
	$sth->finish;

	$sth = $dbh->prepare($DBInsert4);
	eval { $sth->execute(
			$tid->{$number}->{FirstYear},
			$tid->{$number}->{FirstMonth},
			$number
		);};
	$sth->finish;

	$sth = $dbh->prepare($DBInsert3);
	eval { $sth->execute(
			$tid->{$number}->{FirstEndYear},
			$tid->{$number}->{FirstEndMonth},
			$number
		);};
	$sth->finish;
	#<PG
eval { printf( "getting tid %d\n", $number); } ;
	return;
}


sub name_to_tid
{
	my $name = shift;
	my ($tid, $title);
	my $sth = $dbh->prepare($DBQueryAll);
	$sth->execute();
	while ( my $arr_ref = $sth->fetchrow_arrayref )
	{
		($tid, $title) = @$arr_ref;
		next unless(defined $title);
		printf "%s\n", $tid if($title =~ /$name/);
	}
}

sub main
{
	#PG>
	$dbh = DBI->connect($DSN,$DBUser,$DBPass,{RaiseError=>1}) || die $!;
	eval {
  		my $sth = $dbh->prepare($DBCreate);
  		$sth->execute();
  		$sth->finish;
	};
	#<PG
	
		my $base = $_;
		s/^(MAQ|MHD)\-//;
		my $arg = $_;
		if($arg =~ /^(\d+)/) {
			&tid_to_name($arg);
			my $name = encode('cp932', decode( 'utf8', $tid->{$arg}->{title}));
			s/^(\d+)//;
			s/\.//;
			my @s = split(/-/, $`);
			rename
				$base,
				sprintf "%s #%d %s-%s %sch.%s", $name, $s[1], $s[2], $s[3], $s[4], $';
		}

	#PG>
	$dbh->disconnect;
	#<PG
}

my $maxdepth = 1;
my $mindepth = 1;
my $topdir   = ".";
sub wanted {
    # figure out the relative path and depth
    my $relpath = $File::Find::name;
    $relpath =~ s{^\Q$topdir\E/?}{};
    my $depth = File::Spec->splitdir($relpath);

    defined $maxdepth && $depth >= $maxdepth
       and $File::Find::prune = 1;

    defined $mindepth && $depth < $mindepth
       and return;

	return unless( -f $_);
	return unless /\.MP4$/;
	return unless /^(MAQ|MHD)\-/;

	&main ($_);
}

find \&wanted, $topdir;
