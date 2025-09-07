from os.path import expanduser
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import pandas as pd
import os, sys, argparse, copy, time
import math

prop = font_manager.FontProperties(fname="../fonts/LinLibertine_Mah.ttf")
mpl.rcParams['font.family'] = prop.get_name()
mpl.rcParams['text.usetex'] = True
fontsize = 32
mpl.rcParams.update({'font.size': fontsize})

def main(args):
    
    df = pd.read_csv(args.path, sep=",")
    methods = [
        ['default', 'black' , 'solid', 'D', 'RocksDB'],
        ['mnemosyne', 'blue', 'solid', 'p', 'Mnemosyne'],
        ['mnemosyne-plus', 'red', 'solid', 'x', 'Mnemosyne$^+$']
    ]

    for method in methods:
        if method[0] in df:
            df[method[0]] /= 10000
            ax = df[method[0]].plot(color=method[1], linestyle=method[2], marker=method[3], markersize=12, figsize=(8,6), fillstyle='none', label=method[4])
    
    x = []
    xlabels = []
    for i,y in enumerate(df['scales']):
        x.append(i)
        xlabels.append(y)
    ax.set_xticks(x)
    ax.set_xticklabels(xlabels)
    ax.set_xlabel('Scalability')
    
    ax.set_ylabel('Tput (10$K$ops/s)')
    if args.ymax != -1000:
        ax.set_ylim(bottom=0.0, top=args.ymax)
        ax.set_yticks([i*5 for i in range(int(math.ceil(args.ymax/5) + 1))])
    else:
        ax.set_ylim(bottom=0.0, top=40)
        ax.set_yticks([0,10,20,30,40])

    
        
    if args.showLegend:
        plt.legend(loc=args.legendLoc, ncols=1, columnspacing=0.6, labelspacing=0.2,borderaxespad=0.1,handletextpad=0.2,handlelength=2.0,fontsize=fontsize-2)
    plt.tight_layout()
    ax.figure.savefig(args.name, bbox_inches = "tight", dpi=900) 


if __name__ == "__main__":
    parser = argparse.ArgumentParser('vary-bpk-opt-vs-monkey-microbenchmark-plot')
    parser.add_argument('--path',help='suffix to be plot',type=str, default='../YCSB-cpp/exp-th16_dynamic_cmpct/ycsb_scalability_workloadb_dynamic_exp.txt')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/ycsb_scalability_workloadb_dynamic.pdf')
    parser.add_argument('--showLegend', action='store_true', help='show the legend')
    parser.add_argument('--legendLoc',help='the location of the legend', default='upper right')
    parser.add_argument('--ymax',help='the maximum y value', type=float, default=-1000)
    
    args = parser.parse_args()
    main(args)
