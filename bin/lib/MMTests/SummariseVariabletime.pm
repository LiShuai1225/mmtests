# SummariseVariabletime.pm
package MMTests::SummariseVariabletime;
use MMTests::Extract;
use VMR::Stat;
our @ISA = qw(MMTests::Extract);
use strict;

sub initialise() {
	my ($self, $reportDir, $testName) = @_;
	my $opName = "Ops";
	if (defined $self->{_Opname}) {
		$opName = $self->{_Opname};
	}

	$self->{_ModuleName} = "SummariseVariabletime";
	$self->SUPER::initialise();

	$self->{_FieldLength} = 12;
	my $fieldLength = $self->{_FieldLength};
	$self->{_FieldFormat} = [ "%-${fieldLength}s",  "%${fieldLength}d", "%${fieldLength}.2f", "%${fieldLength}.2f", "%${fieldLength}d" ];
	$self->{_FieldHeaders} = [ "Type", "Sample", $self->{_Opname} ? $self->{_Opname} : "Ops" ];
	$self->{_RatioPreferred} = "Lower";

	$self->{_SummaryLength} = 16;
	$self->{_SummaryHeaders} = [ "Unit", "Min", "1st-qrtle", "2nd-qrtle", "3rd-qrtle", "Max-90%", "Max-93%", "Max-95%", "Max-99%", "Max", "Mean", "Best99%Mean", "Best95%Mean", "Best90%Mean", "Best50%Mean", "Best10%Mean", "Best5%Mean", "Best1%Mean" ];
	$self->{_SummariseColumn} = 2;
	$self->{_TestName} = $testName;
}

sub printPlot() {
	my ($self, $subHeading) = @_;
	my @data = @{$self->{_ResultData}};
	my $fieldLength = $self->{_FieldLength};
	my $column = 1;

	$subHeading = $self->{_DefaultPlot} if $subHeading eq "";
	$subHeading =~ s/\s+//g;

	my @units;
	my @index;
	my @row;
	my $samples = 0;
	foreach my $row (@data) {
		@{$row}[0] =~ s/\s+//g;
		if (@{$row}[0] eq $subHeading || $self->{_PlotType} eq "simple") {
			push @index, @{$row}[1];
			push @units, @{$row}[2];
			$samples++;
		} elsif (@{$row}[0] eq $subHeading && $self->{_PlotType} eq "simple-filter") {
			push @index, @{$row}[1];
			push @units, @{$row}[2];
			$samples++;
		}

	}
	if ($self->{_PlotType} eq "simple" || $self->{_PlotType} eq "simple-filter") {
		for (my $samples = 0; $samples <= $#index; $samples++) {
			if (int $index[$samples] == $index[$samples]) {
				printf("%-${fieldLength}d %${fieldLength}.3f\n", $index[$samples] - $index[0], $units[$samples]);
			} else {
				printf("%-${fieldLength}f %${fieldLength}.3f\n", $index[$samples] - $index[0], $units[$samples]);
			}
		}
	} else {
		$self->_printCandlePlotData($fieldLength, @units);
	}
}

sub printReport() {
	my ($self) = @_;
	$self->{_PrintHandler}->printRow($self->{_ResultData}, $self->{_FieldLength}, $self->{_FieldFormat});
}

sub extractSummary() {
	my ($self, $subHeading) = @_;
	my @_operations = @{$self->{_Operations}};
	my @data = @{$self->{_ResultData}};

	if ($subHeading ne "") {
		$#_operations = 0;
		$_operations[0] = $subHeading;
	}

	my $bestOp = "calc_lowest_mean";
	if ($self->{_RatioPreferred} eq "Higher") {
		$bestOp = "calc_highest_mean";
	}

	foreach my $operation (@_operations) {
		no strict  "refs";

		my @units;
		my @row;
		my $samples = 0;
		foreach my $row (@data) {
			if (@{$row}[0] eq "$operation") {
				push @units, @{$row}[2];
				$samples++;
			}
		}
		my $quartilesRef = calc_quartiles(@units);
		my @quartiles = @{$quartilesRef};
		push @row, $operation;
		push @row, calc_min(@units);
		push @row, $quartiles[1];
		push @row, $quartiles[2];
		push @row, $quartiles[3];
		push @row, $quartiles[90];
		push @row, $quartiles[93];
		push @row, $quartiles[95];
		push @row, $quartiles[99];
		push @row, $quartiles[4];
		push @row, calc_mean(@units);
		push @row, &$bestOp(99, @units);
		push @row, &$bestOp(95, @units);
		push @row, &$bestOp(90, @units);
		push @row, &$bestOp(50, @units);
		push @row, &$bestOp(10, @units);
		push @row, &$bestOp(5, @units);
		push @row, &$bestOp(1, @units);

		push @{$self->{_SummaryData}}, \@row;
	}

	return 1;

}

sub extractRatioSummary() {
	my ($self, $subHeading) = @_;
	my @_operations = @{$self->{_Operations}};
	my @data = @{$self->{_ResultData}};

	if ($subHeading ne "") {
		$#_operations = 0;
		$_operations[0] = $subHeading;
	}

	$self->{_SummaryHeaders} = [ "Time", "Ratio" ];

	foreach my $operation (@_operations) {

		my @units;
		my @row;
		my $samples = 0;
		foreach my $row (@data) {
			if (@{$row}[0] eq "$operation") {
				push @units, @{$row}[2];
				$samples++;
			}
		}
		my $quartilesRef = calc_quartiles(@units);
		my @quartiles = @{$quartilesRef};
		push @row, $operation;
		push @row, $quartiles[95];

		push @{$self->{_SummaryData}}, \@row;
	}

	return 1;

}


1;
