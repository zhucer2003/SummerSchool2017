
tmp=$SCRATCH/dwtest
if [ ! -d $tmp ]
then
    mkdir $tmp
fi
echo $tmp

cd $tmp
rm -rf staging-example.dat before-stage after-stage

touch example.dat

mkdir before-stage
mkdir before-stage/bin
touch before-stage/bin/executable
touch before-stage/text


sbatch -C mc <<\EOF
#!/bin/bash
#SBATCH --job-name="DW-staging"
#SBATCH --nodes=1
#SBATCH --time=0:05:00
#SBATCH --output=staging.out%j
#DW jobdw access_mode=striped capacity=200GiB type=scratch
#DW stage_in  type=file source=/scratch/snx3000/mvalle/dwtest/example.dat destination=$DW_JOB_STRIPED/example.dat
#DW stage_out type=file destination=/scratch/snx3000/mvalle/dwtest/staging-example.dat source=$DW_JOB_STRIPED/example.dat
#DW stage_in  type=directory source=/scratch/snx3000/mvalle/dwtest/before-stage destination=$DW_JOB_STRIPED/dir
#DW stage_out type=directory destination=/scratch/snx3000/mvalle/dwtest/after-stage source=$DW_JOB_STRIPED/dir
#-----------------------------------------------------------

ls -lR $DW_JOB_STRIPED

EOF
