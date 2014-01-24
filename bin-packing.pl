#!/usr/bin/env perl

###############################################################################
#
# binPacking Copyright (C) 2011 Biucchi Gabriele <mrecotux@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

# list of the items
my @itemList1 = (
	"a", "a", "a", "a", "a",
	"b", "b",
	"c", "c", "c", "c", "c", "c", "c", "c", "c", "c",
	"d",
	"e", "e", "e",
	"f", "f",
	"g", "g", "g",
	"h", "h", "h", "h", "h"
);

# weights of items
my %weights = (
	w => 1504,
	a => 862,
	b => 807,
	c => 563,
	d => 530,
	e => 382,
	f => 314,
	g => 294,
	h => 263
);


############## MAIN  ##############

my $max = 1000;

my $half = int( $max/2 );
my @sortarray;

my $points;
my $rnd1;
my $rnd2;

### first random array
my @array;
for( my $i = 0; $i < $max; $i++ ) {
	$array[$i] = new Boxes(\@itemList1);
	$array[$i]->rndBoxes();
	$array[$i]->compact();
}

### sort the array
@sortarray = sort sortBoxes @array;
$sortarray[0]->printBoxes();
$points = $sortarray[0]->getPoints();

### main loop
while(1) {
	# copy the sorted array
	for( my $i = 0; $i < $half; $i++ ) {
		$array[$i] = $sortarray[$i];
	}

	### childs creation
	for( my $i = 0; $i < $half; $i++ ) {
		$rnd1 = int( rand $half );
		$rnd2 = int( rand $half );
		$array[$half+$i] = sum( $array[$rnd1], $array[$rnd2] );
	}

	### sort the array
	@sortarray = sort sortBoxes @array;
	if( $sortarray[0]->getPoints() < $points ) {
		$points = $sortarray[0]->getPoints();
		$sortarray[0]->printBoxes();
	}
}


############# Utility function ##############

# sort ordering for configurations
sub sortBoxes {
	$a->getPoints() <=> $b->getPoints();
}

# permutation
sub perm {
	my $max = shift;

	my @base;
	my @perm;
	my $r;
	my $i, $j, $k;
	
	for( $i = 0; $i < $max; $i++ ) {
		$base[$i] = $i;
	}
	for( $j = $max; $j > 0; $j-- ) {
		$r = int( rand $j );
		$perm[$j-1] = $base[$r];
		if( $r != ($j-1) ) {
			for( $k = $r; $k < ($j-1); $k++ ) {
				$base[$k] = $base[$k+1];
			}
		}
	}
	return @perm;
}


############# Sum of two boxes ##############

sub sum {
	my $box1 = shift;
	my $box2 = shift;

	my $obj1 = $box1->copy();	# deep copy of input
	my $obj2 = $box2->copy();

	my @item3 = ();
	my @scat;
	my $worktmp;

	$obj1->rndBoxes();
	$obj1->rndElements();
	$obj2->rndBoxes();
	$obj2->rndElements();

	while( !($obj1->isEmpty()) || !($obj2->isEmpty()) ) {

		@scat = $obj1->firstBox();
		if( @scat != 0 ) {
			$obj1->shiftBox();

			push( @item3, @scat );

			$obj2->remove(\@scat);
			$obj2->compact();
		}
		$worktmp = $obj2;
		$obj2 = $obj1;
		$obj1 = $worktmp;
	}
	my $obj3 = new Boxes( \@item3 );
	$obj3->compact();

	$obj3;
}



############# "Boxes" Class ##############

package Boxes;

# create the "Boxes" structure starting from a base configuration
sub new {
	my $class = shift;
	my $itemref = shift;
	my @itemList = @$itemref;

	my @boxBase;
	$boxBase[0][0] = @itemList;			# number of boxes 
	$boxBase[0][1] = 0;				# to lock the print
	$boxBase[0][2] = 0;				# minimum occupied
	$boxBase[0][3] = @itemList; 			# points

	my $lun;
	for( my $i = 1; $i <= $boxBase[0][0]; $i++ ) {
		$lun = 0;
		$boxBase[$i][1] = 1;			# number of elements in the box 
		$boxBase[$i][2] = $itemList[$i-1];	# elements in the box 
		for( my $j = 1; $j <= $boxBase[$i][1]; $j++ ) {
			$lun = $lun + $weights{$boxBase[$i][$j+1]};
		}	
		$boxBase[$i][0] = $weights{w} - $lun;	# free part of the box 
	}

	my $self = \@boxBase;
	bless $self, 'Boxes';
	return $self;
}


# deep copy of the object
sub copy {
	my $self = shift;
	my @boxes = @$self;

	my @boxBase;
	$boxBase[0][0] = $boxes[0][0];		# number of boxes 
	$boxBase[0][1] = $boxes[0][1];		# to lock the print
	$boxBase[0][2] = $boxes[0][2];		# minimum occupied
	$boxBase[0][3] = $boxes[0][3];		# points

	for( my $i = 1; $i <= $boxBase[0][0]; $i++ ) {
		$boxBase[$i][1] = $boxes[$i][1];	# number of elements in the box
		for( my $j = 1; $j <= $boxBase[$i][1]; $j++ ) {
			$boxBase[$i][$j+1] = $boxes[$i][$j+1];
		}	
		$boxBase[$i][0] = $boxes[$i][0];	# free part of the box
	}

	my $self = \@boxBase;
	bless $self, 'Boxes';
	return $self;
}


# get the points of the configuration
sub getPoints {
	my $self = shift;
	my @boxes = @$self;

	return $boxes[0][3];
}


# print the configuration data
sub printBoxes {
	my $self = shift;
	my @boxes = @$self;

	my $len;
	my %count = (
		"a" => 0,
		"b" => 0,
		"c" => 0,
		"d" => 0,
		"e" => 0,
		"f" => 0,
		"g" => 0,
		"h" => 0,
	);

	print "Number of boxes:  " . $boxes[0][0] . "\n";
	print "Minimum occupied: " . $boxes[0][2] . "\n";
	print "Points: " . $boxes[0][3] . "\n";
	for( my $i = 1; $i <= $boxes[0][0]; $i++ ) {
		$len = $weights{w};
		print "box : " . $i . "\n";
		print "\tfree part : " . $boxes[$i][0] . "\n";
		print "\tnumber of elements : " . $boxes[$i][1] . "\n";
		print "\telements : ";
		for( my $j = 1; $j <= $boxes[$i][1]; $j++ ) {
 			print $boxes[$i][$j+1] . " ";
			$len -= $weights{$boxes[$i][$j+1]};
			$count{$boxes[$i][$j+1]}++;
		}
		if( $len != $boxes[$i][0] ) {
			print "ERROR! Actual free part: " . $len;
		}
		print "\n";
	}

	if( $count{a} != 5 || $count{b} != 2 || $count{c} != 10 || $count{d} != 1 || $count{e} != 3 || $count{f} != 2 || $count{g} != 3 || $count{h} != 5 ) {
		print "ERROR!\n";
		for my $key ( keys %count ) {
			my $value = $count{$key};
			print "$key => $value\n";
		}
	}
	print "\n";
}


# return 1 if the structure is empty
sub isEmpty {
	my $self = shift;
	my @boxes = @$self;

	if( $boxes[0][0] > 0 ) {
		return 0;
	}
	else {
		return 1;
	}
}


# remove an array of elements from the configuration
sub remove{
	my $self = shift;
	my $arrayref = shift;

	my @boxes = @$self;
	my @arrayrem = @$arrayref;

	my $item;
	my $found;

	for( my $i = 0; $i < @arrayrem; $i++ ) {
		$item = $arrayrem[$i];
		$found = 0;

        	for( my $j = 1; $j <= $boxes[0][0] && $found == 0; $j++ ) {
			for( my $k = 1; $k <= $boxes[$j][1] && $found == 0; $k++ ) {
				if( $boxes[$j][$k+1] eq $item ) {
					$found = 1;
					$boxes[$j][0] += $weights{$boxes[$j][$k+1]};
					for( my $l = $k+1; $l <= $boxes[$j][1]; $l++ ) {
						$boxes[$j][$l] = $boxes[$j][$l+1];
					}
					$boxes[$j][1] -= 1;
				}
                	}
        	}
	}
}


# returns an array with the elements of the first box
sub firstBox {
	my $self = shift;
	my @boxes = @$self;

	my @exit =();

	if( $boxes[0][0] <= 0 ) {
		return @exit;
	}

	for( my $j = 0; $j < $boxes[1][1]; $j++ ) {
 		$exit[$j] = $boxes[1][$j+2]; 
	}

	@exit;
}


# remove the first box and shift the remaining
sub shiftBox {
	my $self = shift;
	my @boxes = @$self;

	if( $boxes[0][0] <= 1 ) { 
		$boxes[0][0] = 0;
		return 0;
	}

	$boxes[0][0]--;
        for( my $i = 1; $i <= $boxes[0][0]; $i++ ) {
                $boxes[$i][0] = $boxes[$i+1][0];
                $boxes[$i][1] = $boxes[$i+1][1];
                for( my $j = 1; $j <= $boxes[$i][1]; $j++ ) {
                        $boxes[$i][$j+1] = $boxes[$i+1][$j+1];
                }
        }
	my $max;
	$max = $boxes[1][0];
	for( my $i = 2; $i <= $boxes[0][0]; $i++ ) {
		if( $boxes[$i][0] > $max ) {
			$max = $boxes[$i][0];
		}
	}

	$boxes[0][2] = $weights{w} - $max;
	$boxes[0][3] = $boxes[0][0] + ($boxes[0][2]/10000);

	1;
}


# shuffle the boxes 
sub rndBoxes {
	my $self = shift;
	my @boxes = @$self;

	my @exitList;
	my $elements;

	my $numBoxes = $boxes[0][0];
	my @perm = ::perm( $numBoxes );

	for( my $i = 0; $i < $numBoxes; $i++ ) {
		$elements = $boxes[$perm[$i]+1][1]+1;
		for( my $j = 0; $j <= $elements; $j++ ) {
			$exitList[$i][$j] = $boxes[$perm[$i]+1][$j];
		}
	}
	for( my $i = 0; $i < $numBoxes; $i++ ) {
		$elements = $exitList[$i][1]+1;
		for( my $j = 0; $j <= $elements; $j++ ) {
			$boxes[$i+1][$j] = $exitList[$i][$j];
		}
	}
}


# compact
sub compact {
	my $self = shift;
	my @boxes = @$self;
	
	my $empty;
	my $last;
	my $max;

	my $globalexit = 0;

	while( $globalexit == 0 ) {
		$globalexit = 1;
		for( my $i = 1; $i < $boxes[0][0]; $i++ ) {
			for( my $j = 2; $j <= ( $boxes[$i+1][1]+1 ); ) { 
				if( $weights{$boxes[$i+1][$j]} <= $boxes[$i][0] ) {
					$globalexit = 0;
					$boxes[$i][1] += 1;
					$boxes[$i][0] -= $weights{$boxes[$i+1][$j]};
					$boxes[$i][($boxes[$i][1])+1] = $boxes[$i+1][$j];
					$boxes[$i+1][0] += $weights{$boxes[$i+1][$j]};
					for( my $k = $j; $k <= $boxes[$i+1][1]; $k++ ) {
						$boxes[$i+1][$k] = $boxes[$i+1][$k+1];
					}
					$boxes[$i+1][1] -= 1;

				} else {
					$j++;
				}
			}
		}

		$empty = 1;
		for( $last = $boxes[0][0]; ($last >= 1) && ($empty==1); $last-- ) {
			if( $boxes[$last][1] > 0 ) {
				$empty = 0;
			}
		}
		if( $empty == 1 ) {
			$boxes[0][0] = 0;
		}
		else {
			$boxes[0][0] = $last + 1;
		}

	}

	$max = $boxes[1][0];
	for( my $i = 2; $i <= $boxes[0][0]; $i++ ) {
		if( $boxes[$i][0] > $max ) {
			$max = $boxes[$i][0];
		}
	}

	$boxes[0][2] = $weights{w} - $max;
	$boxes[0][3] = $boxes[0][0] + ($boxes[0][2]/10000);
}


# shuffle the elements
sub rndElements {
	my $self = shift;
	my @boxes = @$self;
	
	my $elements;
	my @perm;
	my @exitList;

	my $numBoxes = $boxes[0][0];
	for( my $i = 1; $i <= $numBoxes; $i++ ) {
		$elements = $boxes[$i][1];
		@perm = ::perm( $elements );
		for( my $j = 0; $j < $elements; $j++ ) {
			$exitList[$j] = $boxes[$i][$perm[$j]+2];
		}
		for( my $j = 0; $j < $elements; $j++ ) {
			$boxes[$i][$j+2] = $exitList[$j];
		}
	}
}

