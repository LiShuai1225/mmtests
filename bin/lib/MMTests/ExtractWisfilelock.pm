# ExtractWisfilelock.pm
package MMTests::ExtractWisfilelock;
use MMTests::ExtractWiscommon;
our @ISA = qw(MMTests::ExtractWiscommon);

sub initialise() {
	my ($self, $reportDir, $testName) = @_;
	my $class = shift;
	$self->{_ModuleName} = "ExtractWisfilelock";
	$self->{_DataType}   = MMTests::Extract::DATA_OPS_PER_SECOND;
	$self->{_PlotType}   = "client-errorlines";
	$self->{_PlotXaxis}  = "Threads";

	$self->SUPER::initialise($reportDir, $testName);
}

1;
