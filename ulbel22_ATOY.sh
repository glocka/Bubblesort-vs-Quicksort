#!/bin/bash
echo "TEAM 22"
echo "Gerald Birngruber"
echo "Thomas Finsterbusch"
echo "Volker Seiser"
echo "QUICKSORT TESTPROGRAM"
echo ""
noValideNo=0

# delet results.txt if exists
if [ -e results.txt ]
then
  rm results.txt
fi

# delet clockcyclesworst.txt if exists
if [ -e clockcyclesworst.txt ]
then
  rm clockcyclesworst.txt
fi

# delet clockcyclesav.txt if exists
if [ -e clockcyclesav.txt ]
then
  rm clockcyclesav.txt
fi

# delet stdin.txt if exists
if [ -e stdin.txt ]
then
  rm stdin.txt
fi

# write
echo "Test of ATOY Quicksort with worst case values"
echo "Test of ATOY Quicksort with worst case values" >>results.txt
echo "Please wait..."

#Testbed worst case 
for((NoOfValues=1;NoOfValues<=50;NoOfValues++))
  do
    #if an error occured stop the procedure
    if [ "$noValideNo" -ne "0" ]
    then
      maxno=$((NoOfValues - 2))
      echo "MAXIMUM Numbers of Values to sort with worst case values: ${maxno}"
      echo "MAXIMUM Numbers of Values to sort with worst case values: ${maxno}" >> results.txt
      break
    fi
    
    # delet stdin.txt if exists
    if [ -e stdin.txt ]
    then
      rm stdin.txt
    fi
    
    #create worst case numbers
    for((Values=1;Values<=NoOfValues;Values++))
      do
       
       printf "%04x" $Values >> stdin.txt
       echo -ne '\n' >>stdin.txt
      done
    echo "0000" >> stdin.txt
    
    #sorte the created numbers
      veriwell ulbel22_ATOY.v > output.txt
 
    #check if the sortet numbers are correct
    for((Values=1;Values<=$((NoOfValues - 1));Values++))
      do
        count=$((Values + 1))
        num1=$(head -n$Values stdout.txt|tail -n1)
        num2=$(head -n$count stdout.txt|tail -n1)
        num1="0x${num1}"
        num2="0x${num2}"
        
        if [[ $num2  -eq "0xffff"  || $num1  -eq "0xffff" ]]
        then
          echo "At ${NoOfValues} Values a Overflow occured(3)" >> results.txt
          noValideNo=$NoOfValues
          break
        fi
        
        if [[ $(( $num1 * 1 )) -gt $(( $num2 * 1 )) ]]
        then
          echo "At ${NoOfValues} Values a Overflow occured(2)" >> results.txt
          noValideNo=$NoOfValues
          break
        fi

      done 
      
      #Save Numberso of Clockcycles
      sed -i -n -e :a -e '1,6!{P;N;D;};N;ba' output.txt
      cycles=$(cat output.txt | tail -1 | cut -d: -f2)
      echo "Clock Cycles for ${NoOfValues} Values: ${cycles}" >> clockcyclesworst.txt
    
  done
  
    if [ "$noValideNo" -eq "0" ]
    then
      echo "More than 50 Values can be sorted"
      echo "More than 50 Values can be sorted" >>results.txt
    fi
  
# write
echo "" >>results.txt
echo ""
echo "Test of ATOY Quicksort with random values"
echo "Test of ATOY Quicksort with random values" >>results.txt
echo "Please wait..."
noValideNo=0

#Testbed randome case
for((NoOfValues=1;NoOfValues<=50;NoOfValues++))
  do
    #if an error occured stop the procedure
    if [ "$noValideNo" -ne "0" ]
    then
      maxno=$((NoOfValues - 2))
      echo "MAXIMUM Numbers of Values to sort with random values: ${maxno}"
      echo "MAXIMUM Numbers of Values to sort with random values: ${maxno}" >> results.txt
      break
    fi
    
    # delet stdin.txt if exists
    if [ -e stdin.txt ]
    then
      rm stdin.txt
    fi
    
    #create worst case numbers
    for((Values=1;Values<=NoOfValues;Values++))
      do
       printf "%04x" $(($RANDOM)) >> stdin.txt
       echo -ne '\n' >>stdin.txt
      done
    echo "0000" >> stdin.txt
    
    #sorte the created numbers
      veriwell ulbel22_ATOY.v > output.txt
 
    #check if the sortet numbers are correct
    for((Values=1;Values<=$((NoOfValues - 1));Values++))
      do
        count=$((Values + 1))
        num1=$(head -n$Values stdout.txt|tail -n1)
        num2=$(head -n$count stdout.txt|tail -n1)
        num1="0x${num1}"
        num2="0x${num2}"
        
        if [[ $num2  -eq "0xffff"  || $num1  -eq "0xffff" ]]
        then
          echo "At ${NoOfValues} Values a Overflow occured(3)" >> results.txt
          noValideNo=$NoOfValues
          break
        fi
        
        if [[ $(( $num1 * 1 )) -gt $(( $num2 * 1 )) ]]
        then
          echo "At ${NoOfValues} Values a Overflow occured(2)" >> results.txt
          noValideNo=$NoOfValues
          break
        fi

      done 
      
      #Save Numberso of Clockcycles
      sed -i -n -e :a -e '1,6!{P;N;D;};N;ba' output.txt
      cycles=$(cat output.txt | tail -1 | cut -d: -f2)
      echo "Clock Cycles for ${NoOfValues} Values: ${cycles}" >> clockcyclesav.txt
    
  done

    # delet output.txt if exists
    if [ -e output.txt ]
    then
      rm output.txt
    fi
    
    # delet stdin.txt if exists
    if [ -e stdin.txt ]
    then
      rm stdin.txt
    fi
    
    # delet stdout.txt if exists
    if [ -e stdout.txt ]
    then
      rm stdout.txt
    fi

    # delet veriwell.keyt if exists
    if [ -e veriwell.key ]
    then
      rm veriwell.key
    fi
    
    # delet veriwell.log if exists
    if [ -e veriwell.log ]
    then
      rm veriwell.log
    fi
    
    if [ "$noValideNo" -eq "0" ]
    then
      echo "More than 50 Values can be sorted"
      echo "More than 50 Values can be sorted" >>results.txt
    fi
