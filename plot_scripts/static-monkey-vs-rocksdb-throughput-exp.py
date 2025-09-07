from os.path import expanduser
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import pandas as pd
import numpy as np
import os, sys, argparse, copy, time
import math

prop = font_manager.FontProperties(fname="../fonts/LinLibertine_Mah.ttf")
mpl.rcParams['font.family'] = prop.get_name()
mpl.rcParams['text.usetex'] = True
fontsize = 48
mpl.rcParams.update({'font.size': fontsize})

def main(args):
    
    df = pd.read_csv(args.tput_path, sep=",")
    methods = [
        ['uniform', 'black' , 'solid', 'D', 'RocksDB'],
        ['monkey-bottom-up', 'tab:blue', 'dashed', 'p', 'Monkey (Bottom-Up)'],
        ['monkey-top-down', 'purple', 'dotted', 'p', 'Monkey (Top-Down)'],
        ['mnemosyne', 'red', 'dashdot', 'x', 'Mnemosyne']
    ]

    fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(args.width,12))

    max_tput = 0
    for method in methods:
        key = "tput-" + method[0]
        if key in df:
            tmp = df[key]*100000
            max_tput = max(max_tput, tmp.max())
            ax1.plot(tmp[1:], color=method[1], linestyle=method[2], fillstyle='none', label=method[4])
    
    #ax.set_xticks(x, xlabels)
    #ax.set_xlabel('Operations ($M$)', fontsize=fontsize-6)
    
    
    ax1.set_ylabel('Tput (10Kops/s)', fontsize=fontsize-10)

    if args.tput_ymax > 0:
        ymax = args.tput_ymax
    else:
        ymax = max_tput
    #print(ymax)
    ax1.set_ylim(bottom=0.0, top=ymax)
    ax1.set_yticks([i*args.tput_yinterval for i in range(math.ceil(ymax/args.tput_yinterval+0.5))])
    ax1.tick_params(axis='y', labelsize=fontsize-12)
    if args.showLegend:
        ax1.legend(loc=args.legendLoc, ncol=2, columnspacing=0.2, labelspacing=0.1,handlelength=1.2,fontsize=fontsize-12,handletextpad=0.2)

    df2 = pd.read_csv(args.bpk_path, sep=",")

    max_bpk = 0.0
    for method in methods:
        key = "bpk-" + method[0]
        if key in df2:
            tmp = df2[key][1:]
            max_bpk = max(max_bpk, tmp.max())
            # plotting from the second line since the first line is 0 for 0 operation
            ax2.plot(tmp, color=method[1], linestyle=method[2], fillstyle='none', label=method[4])
    
    x = []
    xlabels = []
    for i,y in enumerate(df['ops']):
        if i%50 == 0:
            x.append(i)
            xlabels.append(str(int(y//1000000)))

    ax2.set_xticks(x, xlabels)
    ax2.set_xlabel('Operations ($M$)', fontsize=fontsize-10)
    
    ax2.tick_params(axis='y', labelsize=fontsize-12)
    ax2.tick_params(axis='x', labelsize=fontsize-12)
    ax2.set_ylabel('Actual Avg Bpk', fontsize=fontsize-10)
    ymax = max_bpk
    if args.bpk_ymax > 0:
        ymax = args.bpk_ymax

    ax2.set_ylim(bottom=0.0, top=ymax)
    ax2.set_yticks([i*args.bpk_yinterval for i in range(math.ceil(max_bpk/args.bpk_yinterval))])
    #ax.set_yticklabels(['%.1f' % (i*2) for i in range(math.ceil(max_bpk/2))])
    #ax.margins(y=0.5)
        
    plt.tight_layout()
    plt.subplots_adjust(hspace=0.1)
    plt.savefig(args.name, bbox_inches = "tight", dpi=900)
    #plt.show()
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser('monkey-vs-mnemosyne-tput-benchmark-plot')
    parser.add_argument('--tput_path',help='suffix to be plot',type=str, default='../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-2.0_throughputs.txt')
    parser.add_argument('--bpk_path',help='suffix to be plot',type=str, default='../skew-aware-bpk-benchmark/exp-throughputs-and-bpk-for-mixed-empty-workloads/workload_type_I-bpk-2.0_tracked_avg_bpk.txt')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/static-monkey-vs-rocksdb-tput-and-bpk-workload_type_I-bpk-2.0.pdf')
    parser.add_argument('--legendLoc',help='the location of the legend', default='lower center')
    parser.add_argument('--showLegend', action='store_true', help='show the legend')
    parser.add_argument('--tput_ymax',help='the maximum throughput', type=float, default=-1000)
    parser.add_argument('--tput_yinterval',help='the interval of ticks for throughput', type=float, default=3)
    parser.add_argument('--bpk_ymax',help='the maximum throughput', type=float, default=-1000)
    parser.add_argument('--bpk_yinterval',help='the interval of ticks for bpk', type=float, default=2)
    parser.add_argument('--width',help='the width of the figure', type=float, default=16)
    
    args = parser.parse_args()
    main(args)
