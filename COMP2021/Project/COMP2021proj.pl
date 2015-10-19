

#!/usr/local/bin/perl5 -w

Import training data and push articles in to a string @articles

open(FI,$ARGV[0]);

@atricles=();

$/= "\'\\t"; #this will devide the file by each artile since every article begins with ¡®\t

while(<FI>){

    $line = $_;

       chomp($line);

       push (@articles,$line);

}

close(FI);

#Determine the class of each article and build vocabulary for each class

       #split article into word vector

  foreach $a (@articles){

       @wordvec = split(/\W/,$a);

       @newarray = grep { !/^$/ } @wordvec;

       $size = $#newarray; #word count for the vector

       #classify each vector and build vocabulary for each class

       if($newarray[-1] eq '0'){

               $c0count++;                             #add count for class 0 article

               $text0 += $size;            #add total word count for class 0

               pop @newarray;            #remove the target variable from array

               foreach $key (@newarray){

                       $key = lc($key);

                       $c0vocab{$key}++; # increment the word's occurence in class 0

               }

       }

       elsif($newarray[-1] eq '1'){

               $c1count++;

               $text1 += $size;

               pop @newarray;

               foreach $key (@newarray){

                       $key = lc($key);

                       $c1vocab{$key}++; # increment the word's occurence in class 1

               }

       }

       else {print "wrong! @newarray\n";}

   }

       foreach $key (keys %c1vocab){

               $vocab{$key} += $c1vocab{$key};}

       foreach $key (keys %c0vocab){

                $vocab{$key} += $c0vocab{$key};}

#calculate probabilities

       #class probability

if($c1count+ $c0count>0 && $c1count+ $c0count>0){

       $ClassP0=$c0count/( $c1count+ $c0count); #<--avoid divide 0

       $ClassP1=$c1count/( $c1count+ $c0count); #same

}

       foreach $key (keys %vocab){

if($text1+keys(%vocab)>0 && $text0+keys(%vocab)>0){ #avoid divide 0

               $CondP1 = ($c1vocab{$key}+1)/($text1+keys(%vocab)); #<-- $c1vocab undefined

               $CondP0 = ($c0vocab{$key}+1)/($text0+keys(%vocab)); #<-- $c0 vocab undefined

}

if($CondP0+ $CondP1>0 && $CondP1+ $CondP0>0){    #avoid divide 0 which causes error

               $c0prob{$key} =$CondP0/($CondP0+ $CondP1);

               $c1prob{$key} =  $CondP1/( $CondP1+ $CondP0 );

}

       }


now it¡¯s end of the model induction. all the conditional probability has been saved in %c1prob and %c0prob for each and every word. all we need to do is to apply the model on test data and see how it works.
newest debug done. Should be error free :) 


#Regard ARGV_[1] to be the test articles
#Below is the test part
#Algorithm: 1. Choose ten most distinguishable word between class 0 and 1
#			2. Calculate the possibility of a test article to be class 0 or 1, and make a decision. Based on $newarray[-1] to see whether the decision is right or wrong.
#			3. prompt out the result. Showing how much percentage of the text classification has been successful


#first find the most distinguishable words
%diffRate = {};
foreach $key (keys %vocab) {
$diffRate{$key} = abs($c0prob{$key} - $c1prob{$key});
}
@rate = values(%diffRate);
@sortRate = reverse(sort(@rate));     #get the list of descending order of diff rate
%reverseRate = reverse(%diffRate);    
%c0prob_t = {};
%c1prob_t = {};
for($i=0;$i<10;$i++) {                #only record top ten as the "distinguish word"
$c0prob_t{$reverseRate{$sortRate[$i]}} = $c0prob{$reverseRate{$sortRate[$i]}};
$c1prob_t{$reverseRate{$sortRate[$i]}} = $c1prob{$reverseRate{$sortRate[$i]}};
}

open(FI2,$ARGV[1]);
@testAtricles=();
while(<FI2>){

    $line = $_;

       chomp($line);

       push (@testArticles,$line);

}

close(FI2);

$right = 0;
$wrong = 0;

$index = 1;
  foreach $a (@testArticles){

       @wordvec = split(/\W/,$a);

       @newarray = grep { !/^$/ } @wordvec;
	   $class0prob = $ClassP0;
	   $class1prob = $ClassP1;
	   
	   foreach $word (@wordvec) {
	   if ($c0prob_t($word) > 0) {
			$class0prob = $class0prob * $c0prob_t{$word};
			$class1prob = $class1prob * $c1prob_t{$word};
		}
	  }
	   if ($class0prob > $class1prob) {
	   print "Test article $index most likely belongs to class 0!\n";
		if($newarray[-1] eq '0') {
		print "Test article $index actually belongs to class 0! The classification is successful!\n";
		$right ++;
		}
		else {
		print "Test article $index actually belongs to class 1! The classification is failed!\n";
		$wrong ++;
		}
	   }
	   else {
	   print "Test article $index most likely belongs to class 1!\n";
		if($newarray[-1] eq '1') {
		print "Test article $index actually belongs to class 1! The classification is successful!\n";
		$right ++;
		}
		else {
		print "Test article $index actually belongs to class 0! The classification is failed!\n";
		$wrong ++;
		}
	   }
	   
	   $index++;
	 }
	 
	$total = $right + $wrong;
	$rightPercent = $right / $total;
	$wrongPercent = $wrong / $total;
	print "-----------------------------------------------------------------------------------------------\n";
	print "Test Result:\n";
	print "There are totally $total test articles. $rightPercent % of them are classified successfully through the model. $wrongPercent % of them are wrongly classified."
      