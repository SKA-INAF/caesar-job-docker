#!/bin/bash

##########################
##    PARSE ARGS
##########################
RUNUSER="caesar"

# - CAESAR OPTIONS
JOB_ARGS=""
INPUTFILE=""
SAVE_REGIONS=""
SAVE_BKGMAP=""
SAVE_RMSMAP=""
SAVE_ZMAP=""
SAVE_RESMAP=""
GLOBAL_BKG=""
BKG_ESTIMATOR=""
BKG_BOXPIX=""
BKG_BOX=""
BKG_GRID=""

NPIX_MIN=""
SEED_THR=""
MERGE_THR=""
NITERS=""
SEED_THR_STEP=""

# - RCLONE OPTIONS
MOUNT_RCLONE_VOLUME=0
MOUNT_VOLUME_PATH="/mnt/storage"
RCLONE_REMOTE_STORAGE="neanias-nextcloud"
RCLONE_REMOTE_STORAGE_PATH="."
RCLONE_MOUNT_WAIT_TIME=10

echo "ARGS: $@"

for item in "$@"
do
	case $item in
		--runuser=*)
    	RUNUSER=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--jobargs=*)
    	JOB_ARGS=`echo "$item" | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			#echo "JOB_ARGS: $JOB_ARGS"
    ;;
		--inputfile=*)
    	INPUTFILE=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--save-regions=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				SAVE_REGIONS="--save-regions"
			fi
    ;;
		--save-bkgmap=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				SAVE_BKGMAP="--save-bkgmap"
			fi
    ;;
		--save-rmsmap=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				SAVE_RMSMAP="--save-rmsmap"
			fi
    ;;
		--save-significancemap=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				SAVE_ZMAP="--save-significancemap"
			fi
    ;;
		--save-residualmap=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				SAVE_RESMAP="--save-residualmap"
			fi
    ;;
		--globalbkg=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				GLOBALBKG="--globalbkg"
			fi
    ;;
		--bkgestimator=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			BKG_ESTIMATOR="--bkgestimator=$OPTVAL"
    ;;
		--bkgboxpix=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			if [ "$OPTVAL" = "1" ] ; then
				BKG_BOXPIX="--bkgboxpix"
			fi
    ;;
		--bkgbox=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			BKG_BOX="--bkgbox=$OPTVAL"
    ;;
		--bkggrid=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			BKG_GRID="--bkggrid=$OPTVAL"
    ;;
		--npixmin=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			NPIX_MIN="--npixmin=$OPTVAL"
    ;;
		--seedthr=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			SEED_THR="--seedthr=$OPTVAL"
    ;;
		--mergethr=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			MERGE_THR="--mergethr=$OPTVAL"
    ;;
		--compactsearchiters=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			NITERS="--compactsearchiters=$OPTVAL"
    ;;
		--seedthrstep=*)
    	OPTVAL=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
			SEED_THR_STEP="--seedthrstep=$OPTVAL"
    ;;

		--mount-rclone-volume=*)
    	MOUNT_RCLONE_VOLUME=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--mount-volume-path=*)
    	MOUNT_VOLUME_PATH=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--rclone-remote-storage=*)
    	RCLONE_REMOTE_STORAGE=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--rclone-remote-storage-path=*)
    	RCLONE_REMOTE_STORAGE_PATH=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;
		--rclone-mount-wait=*)
    	RCLONE_MOUNT_WAIT_TIME=`echo $item | /bin/sed 's/[-a-zA-Z0-9]*=//'`
    ;;

	*)
    # Unknown option
    echo "ERROR: Unknown option ($item)...exit!"
    exit 1
    ;;
	esac
done


# - Set options
DATA_OPTIONS="--inputfile=$INPUTFILE "
RUN_OPTIONS="--run --no-logredir "
SAVE_OPTIONS="$SAVE_REGIONS $SAVE_BKGMAP $SAVE_RMSMAP $SAVE_ZMAP $SAVE_RESMAP "
BKG_OPTIONS="$GLOBALBKG $BKG_ESTIMATOR $BKG_BOXPIX $BKG_BOX $BKG_GRID "
SFINDER_OPTIONS="$NPIX_MIN $SEED_THR $MERGE_THR $NITERS $SEED_THR_STEP "

if [ "$JOB_ARGS" = "" ]; then
	if [ "$INPUTFILE" = "" ]; then
	  echo "ERROR: Empty INPUTFILE argument (hint: you must specify an input file path)!"
	  exit 1
	fi
	JOB_OPTIONS="$RUN_OPTIONS $DATA_OPTIONS $SAVE_OPTIONS $BKG_OPTIONS $SFINDER_OPTIONS "
else
	JOB_OPTIONS="$RUN_OPTIONS $JOB_ARGS " 
fi



###############################
##    MOUNT VOLUMES
###############################
if [ "$MOUNT_RCLONE_VOLUME" = "1" ] ; then

	# - Create mount directory if not existing
	echo "INFO: Creating mount directory $MOUNT_VOLUME_PATH ..."
	mkdir -p $MOUNT_VOLUME_PATH	

	# - Get device ID of standard dir, for example $HOME
	#   To be compared with mount point to check if mount is ready
	DEVICE_ID=`stat "$HOME" -c %d`
	echo "INFO: Standard device id @ $HOME: $DEVICE_ID"

	# - Mount rclone volume in background
	uid=`id -u $RUNUSER`

	echo "INFO: Mounting rclone volume at path $MOUNT_VOLUME_PATH for uid/gid=$uid ..."
	MOUNT_CMD="/usr/bin/rclone mount --daemon --uid=$uid --gid=$uid --umask 000 --allow-other --file-perms 0777 --dir-cache-time 0m5s --vfs-cache-mode full $RCLONE_REMOTE_STORAGE:$RCLONE_REMOTE_STORAGE_PATH $MOUNT_VOLUME_PATH -vvv"
	eval $MOUNT_CMD

	# - Wait until filesystem is ready
	echo "INFO: Sleeping $RCLONE_MOUNT_WAIT_TIME seconds and then check if mount is ready..."
	sleep $RCLONE_MOUNT_WAIT_TIME

	# - Get device ID of mount point
	MOUNT_DEVICE_ID=`stat "$MOUNT_VOLUME_PATH" -c %d`
	echo "INFO: MOUNT_DEVICE_ID=$MOUNT_DEVICE_ID"
	if [ "$MOUNT_DEVICE_ID" = "$DEVICE_ID" ] ; then
 		echo "ERROR: Failed to mount rclone storage at $MOUNT_VOLUME_PATH within $RCLONE_MOUNT_WAIT_TIME seconds, exit!"
		exit 1
	fi

	# - Print mount dir content
	echo "INFO: Mounted rclone storage at $MOUNT_VOLUME_PATH with success (MOUNT_DEVICE_ID: $MOUNT_DEVICE_ID)..."
	ls -ltr $MOUNT_VOLUME_PATH

	# - Create job & data directories
	echo "INFO: Creating job & data directories ..."
	mkdir -p 	$MOUNT_VOLUME_PATH/jobs
	mkdir -p 	$MOUNT_VOLUME_PATH/data

fi


###############################
##    RUN CAESAR JOB
###############################
# - Define run command & args
EXE="/opt/Software/caesar/install/scripts/SFinderSubmitter.sh"
CMD="runuser -l $RUNUSER -g $RUNUSER -c'""$EXE $JOB_OPTIONS""'"

# - Run job
echo "INFO: Running job command: $CMD ..."
eval "$CMD"

