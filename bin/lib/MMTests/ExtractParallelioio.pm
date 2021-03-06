# ExtractParallelio.pm
package MMTests::ExtractParallelioio;
use MMTests::SummariseMultiops;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractParallelioio",
		_DataType    => MMTests::Extract::DATA_TIME_SECONDS,
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

sub extractReport() {
	my ($self, $reportDir, $reportName, $profile) = @_;
	my $lastIOStep = -1;
	my @ioSteps;
	my @ioSizes;
	my $workload;
	$reportDir =~ s/parallelioio/parallelio/;

	# Read the IO steps and workload type
	my $file = "$reportDir/$profile/workload-durations.log";
	open(INPUT, $file) || die("Failed to open $file\n");
	while (<INPUT>) {
		my @elements = split(/\s/);
		$workload = $elements[0];
		if ($lastIOStep != $elements[1]) {
			push @ioSteps, $elements[1];
		}
		$lastIOStep = $elements[1];
	}
	close(INPUT);

	# Read the corresponding IO sizes
	$ioSizes[0] = "0M";
	$file = "$reportDir/$profile/io-durations.log";
	open(INPUT, $file) || die("Failed to open $file\n");
	while (<INPUT>) {
		my @elements = split(/\s/);
		$ioSizes[$elements[0]] = (int $elements[1] / 1048576) . "M";
	}
	close(INPUT);

	# Read the IO durations
	$file = "$reportDir/$profile/io-durations.log";
	open(INPUT, $file) || die("Failed to open $file\n");
	while (<INPUT>) {
		my @elements = split(/\s/);

		push @{$self->{_ResultData}}, [ "io-duration-$ioSizes[$elements[0]]", $elements[2], $elements[3] ];
		if ($elements[2] == 1) {
			push @{$self->{_Operations}}, "io-duration-$ioSizes[$elements[0]]";
		}
	}
	close(INPUT);
}

1;
