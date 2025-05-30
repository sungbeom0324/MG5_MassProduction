Generate 10Ms of events in hepmc.gz format using batch submission of MadGraph5_aMCNLO + Pythia8. \
Example job scheduler is HTCondor in KNU server, Korea.

Step 0. Install MG5 and third party plug-ins [http://epp.hanyang.ac.kr/dokuwiki/doku.php?id=tutorial:madgraph] 
~~~
cd <your_MG5_directory>
git clone <this_url> .
~~~

step 1. MG5 generate your SKELETON output directory.
~~~  
python bin/MG5_aMC
generate p p > t t~
output TT
~~~

step 2. Copy SKELETON into SKELETON_X replicas with enough iseed separation in run_card. The X will correspond to "queue" in condor job.
~~~
chmod +x setup_runs.sh
./setup_runs.sh TT 10
~~~

step 3. Modify run_XXX.sh & .jbl for your SKELETON, and submit it. The output will be aggregated in SE (storage element).
~~~
condor_submit submit submit_TT.jbl
~~~

step 4. Rename hepmc.gz output, seed check, and production check all at once. You may resubmit if there are missing runs.
~~~
chmod +x rename_files.sh
./rename_files.sh TT
~~~

