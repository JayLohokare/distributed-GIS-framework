# hadoop-in-memory-gis
Hadoop extention for in-memory GIS queries

Contains 2 projects I contributed to -
1. Spark based GIS framework
2. Hadoop based in-memory GIS framework

Hadoop framework is based on HadoopGIS, Spark framework on SparkGIS

Hadoop in-memory framework currently works only on Linux Red hat servers.

Change the Shell scripts for modifying the Hadoop/Spark cluster IP addresses.

The in-memory framework achieves compression of data, but keep atleast 1.5x input size availble for RAM for optimal performance. 

The in-memory framework replicates same data set accross entire cluster - TODO Distribute in-memory compute workload to achieve efficiency.

The installtion scripts will automatically install and deploy Hadoop/Spark GIS frameworks.

REDIS is used for the in-memory hadoop framework to achieve independence from system architecture. 
For ensuring that the framework doesnt break, use recommended versions of REDIS, Hadoop, Spark

Mesh compression is achieved using the PPMC algorithm. I modyfied the PPMC library to change the memory read/write to a REDIS read/write.
