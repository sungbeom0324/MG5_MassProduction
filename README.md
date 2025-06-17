Generate 10Ms of events in hepmc.gz format using batch submission of MadGraph5_aMCNLO + Pythia8. \
Example job scheduler is HTCondor in KNU server, Korea.

@ KNU (or any HTCondor cluster.) \
Step 0. Install MG5 and third party plug-ins [http://epp.hanyang.ac.kr/dokuwiki/doku.php?id=tutorial:madgraph] 
~~~
cd <your_MG5_directory>
git clone <this_url> .
chmod +x KNU/*
mv KNU/* .
~~~

step 1. MG5 generate your SKELETON output directory. In this example, TT is the SKELETON.
~~~  
python bin/MG5_aMC
generate p p > t t~
output TT
~~~

step 2. Copy SKELETON into SKELETON_X replicas with enough iseed separation in run_card. The X corresponds to "queue" in condor job.
~~~
./setup_runs.sh TT 10
~~~

step 3. Modify run_SKELETON.sh & .jbl for your process (eg. run_TT.sh, submit_TT.jbl), and submit it. The output will be aggregated in SE (storage element).
~~~
condor_submit submit submit_TT.jbl
~~~

step 4. Rename hepmc.gz output, seed check, and production check all at once. You may resubmit if there are missing runs.
~~~
./rename_files.sh TT
~~~

step 5. Transfer files to HYU/your_data_directory.
~~~

~~~

@ HYU (Slurm Cluster) \
step 6. Delphes simulation in parallel.
~~~
cd <your_data_directory>
git clone <this_url> .
chmod +x HYU/*
mv HYU/* .
./run_delphes.sh TT
~~~
