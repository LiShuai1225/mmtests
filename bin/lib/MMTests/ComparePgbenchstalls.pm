# ComparePgbenchstalls.pm
package MMTests::ComparePgbenchstalls;
use MMTests::Compare;
our @ISA = qw(MMTests::Compare);

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ComparePgbenchstalls",
		_DataType    => MMTests::Compare::DATA_TIME_SECONDS,
		_Variable    => 1,
		_FieldLength => 12,
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

1;
