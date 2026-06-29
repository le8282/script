#!/bin/bash
#Setting
Prefix=$PWD
ComName=
ComPDB=
RecName=
RecPDB=
LigName=
LigPDB=
LigNameInPDB=
LigMol2File=
LigFrcmodFile=
PBRadii=
RemoveTemp=0

#Create tleap.in
cat > tleap.in << EOF
source leaprc.protein.ff19SB
source leaprc.gaff
#loadamberparams ligand.frcmod
#loadamberparams frcmod.ionslm_iod_opc
${LigNameInPDB} = loadmol2 ${LigMol2File}
loadamberparams ${LigFrcmodFile}
WidRec=loadpdb ${RecPDB}
Lig=loadpdb ${LigName}.pdb
WidCom=loadpdb ${ComPDB}
 
set default PBRadii ${PBRadii}
 
saveamberparm WidRec ${RecName}.top ${RecName}.crd 
saveamberparm Lig ${LigName}.top ${LigName}.crd
saveamberparm WidCom ${ComName}.top ${ComName}.crd

quit

EOF

#amber20
export MPI_HOME=/public/software/amber20/AmberTools
export PATH=$PATH:$MPI_HOME/bin
export LD_LIBRARY_PATH=$MPI_HOME/lib:$LD_LIBRARY_PATH
export AMBERHOME=/public/software/amber20
source /public/software/amber20/amber.sh

#Run tleap
tleap -s -f tleap.in 1>/dev/null
mv leap.log tleap.log

###amber18
export MPI_HOME=/public/software/amber18/AmberTools
export PATH=$PATH:$MPI_HOME/bin
export LD_LIBRARY_PATH=$MPI_HOME/lib:$LD_LIBRARY_PATH
export AMBERHOME=/public/software/amber18
source /public/software/amber18/amber.sh


#Remove Temp Files
if [ $RemoveTemp -eq 1 ];then
    rm -f tleap.in
    rm -f tleap.log
    rm -f $LigName".crd"
    rm -f $ComName".crd"
    rm -f $RecName".crd"
fi
