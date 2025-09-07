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
fontsize = 34
mpl.rcParams.update({'font.size': fontsize})

metrics = ['read_latency', 'write_latency', 'tput', 'read_bytes', 'data_blocks']

def main(args):
    
    df = pd.read_csv(args.path, sep=",")
    methods = [
        ['uniform', 'black' , 'solid', 'D', 'RocksDB'],
        ['Mnemosyne', 'blue', 'solid', 'p', 'Mnemosyne'],
        ['Mnemosyne+', 'red', 'solid', 'x', 'Mnemosyne$^+$']
    ]

    for method in methods:
        if method[0] in df:
            if args.metric == 'read_latency' or args.metric == 'write_latency':
                df[method[0]] *= 1000
            elif args.metric == 'tput':
                df[method[0]] = 0.1/df[method[0]]
            elif args.metric == 'read_bytes':
                df[method[0]] /= 1024*1024*1024*100
            elif args.metric == 'data_blocks':
                df[method[0]] -= args.E
                if args.Q != 0:
                    df[method[0]] /= args.Q*1.0
                #print(df[method[0]])
            ax = df[method[0]].plot(color=method[1], linestyle=method[2], marker=method[3], markersize=12, figsize=(args.width,6), fillstyle='none', label=method[4])
    
    x = []
    xlabels = []
    for i,y in enumerate(df['bpk']):
        x.append(i)
        xlabels.append(int(y))
    ax.set_xticks(x)
    ax.set_xticklabels(xlabels)
    ax.set_xlabel('bits-per-key')
    
    if args.metric == 'read_latency':
        ax.set_ylabel('Read latency ($\mu$s/op)')
        if args.ymax != -1000:
            ax.set_ylim(bottom=0.0, top=args.ymax)
        else:
            ax.set_ylim(bottom=0.0, top=45)
            ax.set_yticks([0,15,30,45])
    elif args.metric == 'write_latency':
        ax.set_ylabel('Write latency ($\mu$s/op)')
        ax.set_ylim(bottom=0.0, top=10)
        ax.set_yticks([0,5,10])
    elif args.metric == 'tput':
        ax.set_ylabel('Tput (10$K$ops/s)')
        ax.set_ylim(bottom=0.0, top=13)
        ax.set_yticks([0,3,6,9,12])
    elif args.metric == 'read_bytes':
        ax.set_ylabel(r'Read bytes ($\times$100 GB)')
        ax.set_ylim(bottom=0.0, top=6)
        ax.set_yticks([0,2,4,6,8])
    else:
        ax.set_ylabel('\#data blocks')
        if args.ymax != -1000:
            ax.set_ylim(bottom=-0.1, top=args.ymax)
        else:
            ax.set_ylim(bottom=-0.1, top=2.6)
            ax.set_yticks([0,0.5,1.0,1.5,2.0])
        
        
    if args.showLegend:
        plt.legend(loc=args.legendLoc, ncol=1, columnspacing=0.6, labelspacing=0.2,borderaxespad=0.1,handletextpad=0.2,handlelength=2.0,fontsize=fontsize-2)
    plt.tight_layout()
    ax.figure.savefig(args.name, bbox_inches = "tight", dpi=900)
    if args.showLegend:
        plt.show()
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser('vary-bpk-opt-vs-monkey-microbenchmark-plot')
    parser.add_argument('--path',help='suffix to be plot',type=str, default='../exp/agg_simple_output_by_shorter_bpk/query_latency_Z0.0_ZD0.txt')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/simple_exp_query_latency_Z0.0_ZD0.pdf')
    parser.add_argument('--metric', type=str, help='select a metric type to plot', default='read_latency')
    parser.add_argument('-E',help='number of existing queries', type=int, default=10000000)
    parser.add_argument('-Q',help='number of total queries', type=int, default=10000000)
    parser.add_argument('--showLegend', action='store_true', help='show the legend')
    parser.add_argument('--legendLoc',help='the location of the legend', default='lower right')
    parser.add_argument('--ymax',help='the maximum y value', type=float, default=-1000)
    parser.add_argument('--width',help='the width of the figure', type=float, default=6)
    
    args = parser.parse_args()
    main(args)
