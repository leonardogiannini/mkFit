#! /bin/bash

make -j 32 WITH_ROOT:=1

dir=/data2/slava77/samples/2017/pass-4874f28/initialStep
file=memoryFile.fv3.recT.072617.bin

ECN2=${dir}/10muEta-24to-17Pt1to10/${file}
ECN1=${dir}/10muEta-175to-055Pt1to10/${file}
BRL=${dir}/10muEtaLT06Pt1to10/${file}
ECP1=${dir}/10muEta055to175Pt1to10/${file}
ECP2=${dir}/10muEta17to24Pt1to10/${file}

base=SKL-SP_CMSSW_10mu

for sV in "SimSeed --cmssw-simseeds" "CMSSeed --cmssw-n2seeds"
do echo $sV | while read -r sN sO
    do
	for section in ECN2 ECN1 BRL ECP1 ECP2 
	do
	    for bV in "BH bh" "STD std" "CE ce" "FV fv"
	    do echo $bV | while read -r bN bO
		do
		    oBase=${base}_${sN}_${section}_${bN}
		    echo "${oBase}: validation [nTH:32, nVU:32]"
		    ./mkFit/mkFit ${sO} --sim-val --input-file ${!section} --build-${bO} --num-thr 32 >& log_${oBase}_NVU32int_NTH32_val.txt
		    mv valtree.root valtree_${oBase}.root
		done
	    done
	done
    done
done

make clean

for seed in SimSeed CMSSeed
do
    for section in ECN2 ECN1 BRL ECP1 ECP2
    do
    	oBase=${base}_${seed}_${section}
    	for build in BH STD CE FV
    	do
    	    root -b -q -l plotting/runValidation.C\(\"_${oBase}_${build}\"\)
    	done
    	root -b -q -l plotting/makeValidation.C\(\"${oBase}\"\)
    done

    for build in BH STD CE FV
    do
	oBase=${base}_${seed}
	fBase=valtree_${oBase}
	dBase=validation_${oBase}
	hadd ${fBase}_FullDet_${build}.root `for section in ECN2 ECN1 BRL ECP1 ECP2; do echo -n ${dBase}_${section}_${build}/${fBase}_${section}_${build}.root" "; done`
	root -b -q -l plotting/runValidation.C\(\"_${oBase}_FullDet_${build}\"\)
    done
    root -b -q -l plotting/makeValidation.C\(\"${oBase}_FullDet\"\)
done

make distclean
