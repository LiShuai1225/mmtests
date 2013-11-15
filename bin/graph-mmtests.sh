#!/bin/bash
SCRIPT=`basename $0 | sed -e 's/\./\\\./'`
SCRIPTDIR=`echo $0 | sed -e "s/$SCRIPT//"`

EXTRACT_ARGS=
TEST_LIST=
TMPDIR=
TITLE="--title \"Default Title\""
SMOOTH=

# Do Not Litter
cleanup() {
	if [ "$TMPDIR" != "" -a -d $TMPDIR ]; then
		rm -rf $TMPDIR
	fi
	exit
}
trap cleanup EXIT
trap cleanup INT
trap cleanup TERM

TMPDIR=`mktemp`
if [ "$TMPDIR" = "" ]; then
	echo ERROR: Failed to create temporary diretory
	exit -1
fi
rm $TMPDIR
mkdir $TMPDIR

while [ "$1" != "" ]; do
	case "$1" in
	-n)
		TEST_LIST="`echo $2 | sed -e 's/,/ /g'`"
		shift 2
		;;
	--title)
		TITLE="--title \"$2\""
		shift 2
		;;
	--format)
		FORMAT_CMD="--format \"$2\""
		shift 2
		;;
	--output)
		OUTPUT_CMD="--output \"$2\""
		shift 2
		;;
	--smooth)
		SMOOTH="--smooth bezier"
		shift
		;;
	--logX)
		LOGX=--logX
		shift
		;;
	--logY)
		LOGY=--logY
		shift
		;;
	--x-label)
		FORCE_X_LABEL="$2"
		shift 2
		;;
	--y-label)
		FORCE_Y_LABEL="$2"
		shift 2
		;;
	*)
		EXTRACT_ARGS="$EXTRACT_ARGS $1"
		shift
		;;
	esac
done

TITLES=
for TEST in $TEST_LIST; do
	$SCRIPTDIR/extract-mmtests.pl -n $TEST $EXTRACT_ARGS --print-plot | grep -v nan > $TMPDIR/$TEST || exit
	if [ `wc -l $TMPDIR/$TEST | awk '{print $1}'` -eq 0 ]; then
		continue
	fi
	if [ "$TITLES" = "" ]; then
		TITLES=$TEST
		PLOTS="$TMPDIR/$TEST"
	else
		TITLES="$TITLES,$TEST"
		PLOTS="$PLOTS $TMPDIR/$TEST"
	fi
done

# Read graph information as described by extract-mmtests.pl
TYPE=`$SCRIPTDIR/extract-mmtests.pl -n $TEST $EXTRACT_ARGS --print-type`
XLABEL=`echo $TYPE | cut -d, -f2`
YLABEL=`echo $TYPE | cut -d, -f3`
PLOTTYPE=`echo $TYPE | cut -d, -f4`
if [ "$XLABEL" = "" ]; then
	XLABEL="Unknown X Label"
fi
if [ "$YLABEL" = "" ]; then
	YLABEL="Unknown Y Label"
fi
if [ "$PLOTTYPE" != "" ]; then
	PLOTTYPE=--$PLOTTYPE
fi

# Override certain graph options if requested
if [ "$FORCE_X_LABEL" != "" ]; then
	XLABEL=$FORCE_X_LABEL
fi
if [ "$FORCE_Y_LABEL" != "" ]; then
	YLABEL=$FORCE_Y_LABEL
fi

if [ "$TITLES" != "" ]; then
	eval $SCRIPTDIR/plot $TITLE $PLOTTYPE $SMOOTH $FORMAT_CMD $OUTPUT_CMD $OUTPUT \
		$LOGX $LOGY \
		--xlabel \"$XLABEL\" \
		--ylabel \"$YLABEL\" \
		--titles $TITLES \
		$PLOTS
fi
