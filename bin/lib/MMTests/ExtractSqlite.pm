# ExtractSqlite.pm
package MMTests::ExtractSqlite;
use MMTests::SummariseVariableops;
use VMR::Report;
our @ISA = qw(MMTests::SummariseVariableops);

use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractSqlite",
		_DataType    => MMTests::Extract::DATA_TRANS_PER_SECOND,
		_ResultData  => [],
	};
	bless $self, $class;
	return $self;
}

sub extractReport() {
	my ($self, $reportDir, $reportName, $profile) = @_;
	my $exclude_warmup = 0;
	my $file = "$reportDir/$profile/sqlite.log";

	open(INPUT, $file) || die("Failed to open $file\n");
	while (<INPUT>) {
		my @elements = split(/\s+/);
		next if $elements[0] eq "warmup";

		$exclude_warmup = 1;
		last;
	}
	seek(INPUT, 0, 0);

	my $nr_sample = 0;
	while (<INPUT>) {
		my @elements = split(/\s+/);
		next if $exclude_warmup && $elements[0] eq "warmup";
		push @{$self->{_ResultData}}, ["Trans", $nr_sample++, $elements[1]];
	}
	close INPUT;

	$self->{_Operations} = [ "Trans" ];
}
1;
