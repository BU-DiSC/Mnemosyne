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
mpl.rcParams.update({'font.size': 23})


def main(args):
    
    fig, ax = plt.subplots(figsize=(6,4))
    df = pd.read_csv(args.path, sep=",")
    methods = [
        ['naiive', 'dashed', 'naiive'],
        ['dynamic_compaction_aware', 'solid', 'Merlin']
    ]

    #print(df['ops'].to_list())
    for method in methods:
        name = "euclidean-distance-" + method[0]
        if name in df:
            temp = pd.Series(df[name].to_list())
            ax.plot(df['ops'].to_list(), temp.to_list(), color='black', linestyle=method[1], label=method[2])
            #print(temp.to_list())
    
    x = [0]
    xlabels = [0]
    interval_text = "\#Ingestions"
    interval_unit = ""
    interval_numeric_unit = 1
    if args.interval >= 1000000:
        interval_unit = 'M'
        interval_numeric_unit = 1000000
    elif args.interval >= 1000:
        interval_unit = 'K'
        interval_numeric_unit = 1000

    for i,y in enumerate(df['ops']):
        if y%(args.interval) == 0:
            x.append(y)
            xlabels.append((f'%.0f' % (float(y)*1.0/interval_numeric_unit))+interval_unit)
   
    ax.set_ylabel('Euclidean Distance')
    ax.set_ylim(bottom=0.0, top=args.euclidean_distance_ymax)
    ax.set_yticks([i*args.euclidean_distance_ymax/5 for i in range(6)])

    ax.legend(bbox_to_anchor=(1, 1.3), loc='upper right', ncol=2, columnspacing=0.3, handletextpad=0.3, labelspacing=0.2, handlelength=1, fontsize='small')
    ax2 = ax.twinx()
    ax2.set_ylabel('Cosine Similarity', color='tab:red')
    ax2.set_yticks([0.0,0.5,1.0])
    ax2.tick_params(axis='y', labelcolor='tab:red')
    ax2.set_ylim(bottom=0.0, top=1.0)
    #print(df['ops'].to_list())
    for method in methods:
        name = "cosine-similarity-" + method[0]
        if name in df:
            temp = pd.Series(df[name].to_list())
            ax2.plot(df['ops'].to_list(), temp.to_list(), color='tab:red', linestyle=method[1])
            #print(temp.to_list())

    ax.set_xticks(x)
    ax.set_xticklabels(xlabels)
    ax.set_xlabel(interval_text)
    
    #legend2 = plt.legend(['Legend 2'], loc='upper center')
    #plt.gca().add_artist(legend2)
    plt.tight_layout()
    ax.figure.savefig(args.name, bbox_inches = "tight", dpi=900)
    #plt.show()
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser('vary-bpk-opt-vs-monkey-microbenchmark-plot')
    parser.add_argument('--path',help='path to experimental results',type=str, default='../skew-aware-bpk-benchmark/query_statistics_est_benchmark_result/bottom_up_Z0.5_ZD0_num_empty_point_reads_stats_diff.txt')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/bottom_up_Z0.5_ZD0_num_empty_point_reads_stats_diff.pdf')
    parser.add_argument('--interval',help='the interval of collecting data', type=int, default=2000000)
    parser.add_argument('--euclidean_distance_ymax',help='the maximum value of euclidean distance', type=int, default=60000000)
    parser.add_argument('--showLegend', action='store_true', help='show the legend')
    args = parser.parse_args()
    main(args)
