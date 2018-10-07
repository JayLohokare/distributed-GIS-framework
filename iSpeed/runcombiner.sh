
#! /bin/bash

# parameters: inputpathdir outputdir prefix
# example /tmp /tmp compressed

echo "Running combiner"


if [ $# -ne 1 ]
  then
    echo "Not enough arguments. Need the prefix of the output directory "
    exit 1
fi

#default option
targetdir=/scratch/hadoopgis3d/tmpbin

inputbindir=/tmp
commonprefix=compressionoutputtask
outputfile=/scratch/hadoopgis3d/allbin
outputmbbs=/scratch/hadoopgis3d/allmbbs

echo "Copying data from nodes to the current node"
# currently hard coding the list of nodes
for i in bmidb0 bmidb1 bmidb2 bmidb3 bmidb4
do
        echo "copying data from node ${i}"
        scp ${i}:"${inputbindir}/${commonprefix}*" ${targetdir}"/"
        # for now do not remove yet
        #ssh ${i} "rm ${inputbindir}/${commonprefix}*"
done

# getting the total/global index
hdfs dfs -cat "$1""_mbb/0/*" | ${HADOOPGIS_BIN_PATH}/compress_combine --inputbin  ${targetdir} --outputbin ${outputfile} > ${outputmbbs}

# Putting back the file to HDFS as input for Resque
hdfs dfs -rm -f "$1""_inputresque"
hdfs dfs -put -f ${outputmbbs} "$1""_inputresque"


#So far, the code has run a mapper to find MBBs, which creates multiple files on HDFS. Then, compress_combine combines all these HDFS outputs and combines them into one file on HDFS


# Remove all shared memory segments on all nodes
for i in {0..4} ; do ssh bmidb$i "ipcrm -M 0x0000162e" ; done

# Run loader
echo "Running loader to load compressed data on individual nodes"

echo "Testing loading on node bmidb4"

${HADOOPGIS_BIN_PATH}/compress_load -n ${outputfile}

if [ $? -eq 0 ]; then
    echo "Succeeded loading on bmidb4"
else
    echo "Failed to load. Exiting"
    exit 1
fi

# excluding the current node bmidb4
for i in bmidb0 bmidb1 bmidb2 bmidb3
do
        echo "copying data to node ${i}"
        # copying the executable (should take a very short time
        scp ${HADOOPGIS_BIN_PATH}/compress_load ${i}:${HADOOPGIS_BIN_PATH}/compress_load
        # copying the binary file containing all compressed data (might take some time)
        scp ${outputfile} ${i}:${outputfile}
        echo "loading data remotely"
        ssh $i "${HADOOPGIS_BIN_PATH}/compress_load -n ${outputfile}"
        # for now do not remove yet
        #ssh i "rm $1/$3*"
done
