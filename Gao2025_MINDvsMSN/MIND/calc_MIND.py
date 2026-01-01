import sys
import os
sys.path.insert(1, '/home/huyang/Software/PyPackages/MIND')
from MIND import compute_MIND
curr_sub = sys.argv[1]
curr_sub = curr_sub.strip()
## FreeSurfer recon-all folder
fs_dir = '/home/huyang/Projects/HuYang/HY_20250708/PROCDATA/STATS/T1/FSDATA/' + curr_sub
if os.path.exists(fs_dir):
    ## Specify features to include in MIND calculation
    fs_features = ['CT','MC','Vol','SD','SA']
    ## Specify parcellation
    fs_parc = ['Schaefer.300Parcels.7Networks', '500.aparc']
    for curr_parc in fs_parc:
        ## Calculate MIND metric
        mind_out = compute_MIND(fs_dir, fs_features, curr_parc)
        ## Save
        out_fname = '/home/huyang/Projects/HuYang/HY_20250708/PROCDATA/STATS/T1/MIND/' + curr_sub + '_' + curr_parc + '_FF.txt'
        mind_out.to_csv(out_fname, sep=' ', index=False)
        ## Calculate MIND based on the thickness feature only
        mind_out = compute_MIND(fs_dir, ['CT'], curr_parc, resample=True)
        ## Save
        out_fname = '/home/huyang/Projects/HuYang/HY_20250708/PROCDATA/STATS/T1/MIND/' + curr_sub + '_' + curr_parc + '_CT.txt'
        mind_out.to_csv(out_fname, sep=' ', index=False)
        ## Calculate MIND based on the volume feature only
        mind_out = compute_MIND(fs_dir, ['Vol'], curr_parc, resample=True)
        ## Save
        out_fname = '/home/huyang/Projects/HuYang/HY_20250708/PROCDATA/STATS/T1/MIND/' + curr_sub + '_' + curr_parc + '_CV.txt'
        mind_out.to_csv(out_fname, sep=' ', index=False)


