#!/usr/bin/perl
###############################################################################
#
#    Zevenet Software License
#    This file is part of the Zevenet Load Balancer software package.
#
#    Copyright (C) 2014-today ZEVENET SL, Sevilla (Spain)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

use strict;

sub getFile
{
	&zenlog( __FILE__ . ":" . __LINE__ . ":" . ( caller ( 0 ) )[3] . "( @_ )",
			 "debug", "PROFILING" );
	my $path = shift;

	unless ( -f $path )
	{
		&zenlog( "Could not find file '$path'" );
		return;
	}

	open ( my $fh, '<', $path );

	unless ( $fh )
	{
		&zenlog( "Could not open file '$path': $!" );
		return;
	}

	my $content;

	binmode $fh;
	{
		local $/ = undef;
		$content = <$fh>;
	}

	close $fh;

	return $content;
}

sub setFile
{
	&zenlog( __FILE__ . ":" . __LINE__ . ":" . ( caller ( 0 ) )[3] . "( @_ )",
			 "debug", "PROFILING" );
	my $path    = shift;
	my $content = shift;

	unless ( defined $content )
	{
		&zenlog( "Trying to save undefined content" );
		return 0;
	}

	open ( my $fh, '>', $path );

	unless ( $fh )
	{
		&zenlog( "Could not open file '$path': $!" );
		return 0;
	}

	binmode $fh;
	print $fh $content;

	unless ( close $fh )
	{
		&zenlog( "Could not save file '$path': $!" );
		return 0;
	}

	return 1;
}

sub saveFileHandler
{
	&zenlog( __FILE__ . ":" . __LINE__ . ":" . ( caller ( 0 ) )[3] . "( @_ )",
			 "debug", "PROFILING" );
	my $path       = shift;
	my $content_fh = shift;

	unless ( defined $content_fh )
	{
		&zenlog( "Trying to save undefined file handler" );
		return 0;
	}

	open ( my $fh, '>', $path );

	unless ( $fh )
	{
		&zenlog( "Could not open file '$path': $!" );
		return 0;
	}

	binmode $fh;
	while ( my $line = <$content_fh> )
	{
		print $fh $line;
	}

	unless ( close $fh )
	{
		&zenlog( "Could not save file '$path': $!" );
		return 0;
	}

	return 1;

	# Insert an array in a file before or after a pattern
	sub insertFileWithPattern
	{
		my ( $file, $array, $pattern, $opt ) = @_;
		my $err = 0;

		$opt //= 'after';

		my $index = 0;
		my $found = 0;
		tie my @fileconf, 'Tie::File', $file;

		foreach my $line ( @fileconf )
		{
			if ( $line =~ /$pattern/ )
			{
				$found = 1;
				last;
			}
			$index++;
		}

		return 1 if ( !$found );

		$index++ if ( $opt eq 'after' );

		splice @fileconf, $index, 0, @{ $array };
		untie @fileconf;

		return $err;
	}
}

sub createFile
{
	my $file = shift;
	my $fh;

	if ( -f $file )
	{
		&zenlog( "The file $file already exists", "error", "System" );
		return 1;
	}

	if ( !open ( $fh, '>', $file ) )
	{
		&zenlog( "The file $file could not be created", "error", "System" );
		return 2;
	}
	close $fh;

	return 0;
}

1;
