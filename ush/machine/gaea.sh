#!/bin/bash

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model location

  external_model=${1}
  external_file_fmt=${2}

  case ${external_model} in

    "FV3GFS")
      location='/lustre/f2/dev/Mark.Potts/EPIC/SRW/model_data/FV3GFS/${yyyymmdd}${hh}'
      ;;

  esac
  echo ${location:-}
}

export PROJ_LIB=/lustre/f2/dev/role.epic/contrib/miniconda3/4.12.0/envs/regional_workflow/share/proj
export PATH=${PATH}:/lustre/f2/deve/role.epic/contrib/miniconda3/4.12.0/envs/regional_workflow/bin

EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_ICS})}

# System scripts to source to initialize various commands within workflow
# scripts (e.g. "module").
if [ -z ${ENV_INIT_SCRIPTS_FPS:-""} ]; then
  ENV_INIT_SCRIPTS_FPS=( "/etc/profile"  "/lustre/f2/dev/role.epic/contrib/Lmod_init.sh" )
fi


# Commands to run at the start of each workflow task.
PRE_TASK_CMDS='{ ulimit -s unlimited; ulimit -a; }'

# Architecture information
WORKFLOW_MANAGER="rocoto"
SLURM_NATIVE_CMD="-M c3"
NCORES_PER_NODE=${NCORES_PER_NODE:-32}
SCHED=${SCHED:-"slurm"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"normal"}
QUEUE_HPSS=${QUEUE_DEFAULT:-"normal"}
QUEUE_FCST=${QUEUE_DEFAULT:-"normal"}
WTIME_MAKE_LBCS="00:60:00"

# UFS SRW App specific paths
staged_data_dir="/lustre/f2/pdata/ncep/UFS_SRW_App/v2p0"
FIXgsm=${FIXgsm:-"${staged_data_dir}/fix/fix_am"}
FIXaer=${FIXaer:-"${staged_data_dir}/fix/fix_aer"}
FIXlut=${FIXlut:-"${staged_data_dir}/fix/fix_lut"}
TOPO_DIR=${TOPO_DIR:-"${staged_data_dir}/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"${staged_data_dir}/fix/fix_sfc_climo"}
TEST_EXTRN_MDL_SOURCE_BASEDIR="${staged_data_dir}/input_model_data"

RUN_CMD_SERIAL="time"
#Run Commands currently differ for GNU/openmpi
#RUN_CMD_UTILS='mpirun --mca btl tcp,vader,self -np $nprocs'
#RUN_CMD_FCST='mpirun --mca btl tcp,vader,self -np ${PE_MEMBER01}'
#RUN_CMD_POST='mpirun --mca btl tcp,vader,self -np $nprocs'
RUN_CMD_UTILS='srun --mpi=pmi2 -n $nprocs'
RUN_CMD_FCST='srun --mpi=pmi2 -n ${PE_MEMBER01}'
RUN_CMD_POST='srun --mpi=pmi2 -n $nprocs'

# MET Installation Locations
MET_INSTALL_DIR=${MET_INSTALL_DIR:-"/usw/met/10.1.2"}
METPLUS_PATH=${METPLUS_PATH:-"/usw/met/METplus/METplus-4.1.3"}
CCPA_OBS_DIR=${CCPA_OBS_DIR:-"${staged_data_dir}/obs_data/ccpa/proc"}
MRMS_OBS_DIR=${MRMS_OBS_DIR:-"${staged_data_dir}/obs_data/mrms/proc"}
NDAS_OBS_DIR=${NDAS_OBS_DIR:-"${staged_data_dir}/obs_data/ndas/proc"}
MET_BIN_EXEC=${MET_BIN_EXEC:-"bin"}
# Test Data Locations
