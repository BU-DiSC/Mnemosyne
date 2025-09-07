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
mpl.rcParams['axes.titleweight'] = 'bold' 
fontsize = 42
mpl.rcParams.update({'font.size': fontsize})

def main(args, id, axes, show_xlabel = False):
    df = pd.read_csv(args.path_ZD0, sep=",")
    methods = [
        ['uniform', 'black' , 'RocksDB', -0.2],
        ['monkey+', 'blue', 'IdealMonkey', 0],
        ['optimal', 'red', 'Optimal', 0.2]
    ]

    ax = axes[id][0]
    title = ax.set_title(args.text0, fontsize=fontsize-2, loc='left')
    #title.set_fontweight('bold')
    # ax.text(0, 1, args.text0, transform=ax.transAxes, fontsize=fontsize-2)
    X_axis = np.arange(df['Z'].size) 
    ymax = 0
    for method in methods:
        if args.Q != 0:
            df[method[0]] = (df[method[0]] - (1.0 - df['Z'])*args.Q)
        ymax = max(ymax, df[method[0]].max())
        ax.bar(X_axis + method[3], df[method[0]], color=method[1], label=method[2], width=0.2)
    if id == 0:
        ax.legend(loc=args.legendLoc, ncol=3, columnspacing=0.6, labelspacing=0.2,borderaxespad=0.05,handletextpad=0.3,handlelength=1.5,fontsize=fontsize-10)

    ax.set_xticks(X_axis)
    ax.set_xticklabels([x  for x in df['Z']])
    # if(show_xlabel):
    #     ax.set_xlabel('Empty Point Query Ratio ($Z$)', fontsize=fontsize-2)
    ax.set_yscale("log")

    # ax.set_ylabel('\#Unnecessarily Accessed Data Blocks', fontsize=fontsize-2)
    df = pd.read_csv(args.path_ZD1, sep=",")
    methods = [
        ['uniform', 'black' , 'RocksDB', -0.2],
        ['monkey+', 'blue', 'IdealMonkey', 0],
        ['optimal', 'red', 'Optimal', 0.2]
    ]

    ax = axes[id][1]
    title = ax.set_title(args.text1, fontsize=fontsize-2, loc='left')
    #title.set_fontweight('bold')
    # ax.text(0, 1, args.text1, transform=ax.transAxes, fontsize=fontsize-2)
    X_axis = np.arange(df['Z'].size) 
    for method in methods:
        if args.Q != 0:
            df[method[0]] = (df[method[0]] - (1.0 - df['Z'])*args.Q)
        ymax = max(ymax, df[method[0]].max())
        ax.bar(X_axis + method[3], df[method[0]], color=method[1], label=method[2], width=0.2)


    ax.set_xticks(X_axis)
    ax.set_xticklabels([x  for x in df['Z']])
    # if(show_xlabel):
    #     ax.set_xlabel('Empty Point Query Ratio ($Z$)', fontsize=fontsize-2)

    ax.set_yscale("log")


    if args.ymax != -1000:
        axes[id][0].set_ylim(top=args.ymax)
    else:
        axes[id][0].set_ylim(top=ymax*5)

    if args.ymax != -1000:
        axes[id][1].set_ylim(top=args.ymax)
    else:
        axes[id][1].set_ylim(top=ymax*5)
   
        
    # if args.showLegend:
    #     plt.legend(loc=args.legendLoc, ncols=3, columnspacing=0.6, labelspacing=0.2,borderaxespad=0.1,handletextpad=0.4,handlelength=2.0,fontsize=fontsize-2)
    # plt.tight_layout()
    # ax.figure.savefig(args.name, bbox_inches = "tight", dpi=900)
    # if args.showLegend:
    #     plt.show()



if __name__ == "__main__":
    parser = argparse.ArgumentParser('ycsb-plot')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/data_blocks_vary_Z.png')
    parser.add_argument('-Q', help='number of total queries', default=15000000)
    parser.add_argument('--legendLoc',help='the location of the legend', default='upper left')
    parser.add_argument('--ymax',help='the maximum y value', type=float, default=-1000)
    parser.add_argument('--bpks',help='the set of bpk', nargs = "+", default=[4, 6, 8])
    
    args = parser.parse_args()
    set_of_bpk = args.bpks
    #print(set_of_bpk)
    # set_of_bpk = ["4.0", "6.0", "8.0"]

    fig, axes = plt.subplots(nrows = len(set_of_bpk), ncols = 2, sharex = True, sharey = 'row', figsize=(12 * 2, 6 * len(set_of_bpk)))
    idx = 0
    x = 'a'
    print(axes.shape)
    for bpk in set_of_bpk:
        args = parser.parse_args()
        args.path_ZD0 = f'../skew-aware-bpk-benchmark/agg_output_by_Z/data_blocks-bpk-{bpk}.0_ZD0.txt'
        args.text0 = f'({x}) bpk={bpk}, uniform'
        x = chr(ord(x) + 1)
        args.path_ZD1 = f'../skew-aware-bpk-benchmark/agg_output_by_Z/data_blocks-bpk-{bpk}.0_ZD1.txt'
        args.text1 = f'({x}) bpk={bpk}, normal'
        x = chr(ord(x) + 1)
        main(args, idx, axes, idx + 1 == len(set_of_bpk))
        idx = idx + 1
    plt.subplots_adjust(hspace=0.02)
    #plt.show() 
    #fig.supylabel('\#Unnecessarily Accessed Data Blocks', fontsize=fontsize)
    #fig.supxlabel('Empty Point Query Ratio ($Z$)', fontsize=fontsize)
    plt.tight_layout()
    plt.savefig(args.name, bbox_inches = "tight", dpi=1400)


