#MACHINE CONFIGURATION
GROUP=""
SYSTEM=1  # 0 - K computer , 1 - qsub cluster
PROC_PER_NODE=24    #computer number of procs per node.
PROC_PER_MEMBER=24  #Number  of procs per ensemble members (torque)
NODES_PER_MEMBER=1  #Number of nodes per ensemble member.
PPSSERVER=hydra     #Hostname of pps server (for perturbation generation and post processing)
MAX_RUNNING=5       #Maximum number of simultaneous processes running in PPS servers.
ELAPSE="00:10:00"   #MAXIMUM ELAPSE TIME (MODIFY ACCORDING TO THE SIZE OF THE DOMAIN AND THE RESOLUTION)
MAX_BACKGROUND_JOBS=128

TOTAL_NODES_FORECAST=1
TOTAL_NODES_LETKF=1

#These options control job split (in case of big jobs)
#Job split is performed authomaticaly if the number of ensemble members is
#larger than MAX_MEMBER_PER_JOB.
MAX_MEMBER_PER_JOB=60      #Number of members included on each job.
MAX_SUBMITT_JOB=1          #Maximum number of jobs that can be submitted to the queue.

