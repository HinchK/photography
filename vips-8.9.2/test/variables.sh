top_srcdir=/home/runner/work/photo-wall/photo-wall/vips-8.9.2
PYTHON=@PYTHON@
# we need a different tmp for each script since make can run tests in parallel
tmp=$top_srcdir/test/tmp-$$
test_images=$top_srcdir/test/test-suite/images
image=$test_images/sample.jpg
mkdir -p $tmp
vips=$top_srcdir/tools/vips
vipsthumbnail=$top_srcdir/tools/vipsthumbnail
vipsheader=$top_srcdir/tools/vipsheader

# we need bc to use '.' for a decimal separator
export LC_NUMERIC=C

# test for file format supported
test_supported() {
	format=$1

	if $vips $format > /dev/null 2>&1; then
		result=0
	else
		echo "support for $format not configured, skipping test"
		result=1
	fi

	return $result
}

# is a difference beyond a threshold? return 0 (meaning all ok) or 1 (meaning
# error, or outside threshold)
break_threshold() {
	diff=$1
	threshold=$2
	return $(echo "$diff <= $threshold" | bc -l)
}

# subtract, look for max difference less than a threshold
test_difference() {
	before=$1
	after=$2
	threshold=$3

	$vips subtract $before $after $tmp/difference.v
	$vips abs $tmp/difference.v $tmp/abs.v 
	dif=$($vips max $tmp/abs.v)

	if break_threshold $dif $threshold; then
		echo "save / load difference is $dif"
		exit 1
	fi
}
