#run spatial join

#compile the framework
make queryprocessor_3d DEBUGTIME=1 DEBUG=1

#data compression first
../build/bin/queryprocessor_3d -t st_intersects -a your_hdfs_path/3Ddata/spjoin/testdata/d1 -b your_hdfs_path/3Ddata/spjoin/testdata/d2 -h your_hdfs_path/3Ddata/spjoin/testdata/output/ -q spjoin -s 1.0 -n 240 -u fg_3d --bucket 4000 -f tileid,1:1,2:1,intersect_volume -j 1 -i 1 --compression --overwrite

#combine all binary data and mbb outputs
../build/bin/runcombiner.sh your_hdfs_path/3Ddata/spjoin/testdata/output

hdfs dfs -rm -r your_hdfs_path/3Ddata/spjoin/testdata/output/output_partidx
hdfs dfs -rm -r your_hdfs_path/3Ddata/spjoin/testdata/output/output_joinout

 #run spatial join
../build/bin/queryprocessor_3d -t st_intersects your_hdfs_path/3Ddata/spjoin/testdata/d1 -b your_hdfs_path/3Ddata/spjoin/testdata/d2 -h your_hdfs_path/3Ddata/spjoin/testdata/output/ -q spjoin -s 1.0 -n 240 -u fg_3d --bucket 4000 -f tileid,1:1,2:1 -j 1 -i 1 --spatialproc --decomplod 100 --overwrite
