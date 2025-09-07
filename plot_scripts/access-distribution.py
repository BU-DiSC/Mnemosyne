from os.path import expanduser
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import pandas as pd
import os, sys, argparse, copy, time
import math
import numpy as np

prop = font_manager.FontProperties(fname="../fonts/LinLibertine_Mah.ttf")
mpl.rcParams['font.family'] = prop.get_name()
mpl.rcParams['text.usetex'] = True
fontsize = 36
mpl.rcParams.update({'font.size': fontsize})

def main(args):
    
    distributions = [
        ['Normal_Dis_NDEV3.0', 'brown' , 'dashed', 'Normal $(\sigma = 3.0)$'],
        ['Normal_Dis_NDEV4.0', 'gray', 'dashdot', 'Normal $(\sigma = 4.0)$'],
        ['Normal_Dis_NDEV5.0', 'orange', 'dotted', 'Normal $(\sigma = 5.0)$'],
        ['Uniform_Dis', 'black', 'solid', 'Uniform'],
    ]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    for partial_path, color, linestyle, label in distributions:
      path = args.prefix_path + "/" + partial_path + "_query_stats.txt"
      df = pd.read_csv(path, sep=' ', names=['fid', 'existing queries', 'non-existing queries'])
      df['access frequency'] = df['existing queries'] + df['non-existing queries']
      # C = Z[1:]
      df = df[1:]
      df = df.sort_values(['access frequency', 'fid'], ascending=[0, 0])
      # C = Z[1:].sort_values()
      # print(df)
      X = df['access frequency']
      # print("X = ", X)
      # X = (X - np.min(X)) / (np.max(X - np.min(X)))
      i = 0
      xx = []
      yy = []
      j = 0
      for x in X: 
          i = i + 1
          j = j + x
          xx.append(i / len(X))
          yy.append(j)
      yy /= np.sum(X)
      ax.plot(xx, yy, color=color, label=label, linestyle=linestyle, linewidth=3)
    # ax.set_yscale('logit')
    if args.showLegend:
      ax.legend(loc=args.legendLoc, ncol=1, columnspacing=0.6, labelspacing=0.2,fontsize=fontsize-1,borderaxespad=0.3)
    ax.set_ylabel('CDF', fontsize = fontsize - 4)
    # ax.set_xlabel('Frequency', fontsize = fontsize - 2)
    ax.set_xlabel('\# SST files (descending order of \#accesses)', fontsize = fontsize - 4)
    # fig.supylabel('\# SST files', fontsize=fontsize-2)
    

    # fig.supylabel("\# queries")
    #plt.show()
    plt.tight_layout()
    fig.savefig(args.name, bbox_inches = "tight", dpi=900)
            
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser('vary-bpk-opt-vs-monkey-microbenchmark-plot')
    parser.add_argument('--prefix_path',help='prefix path of distribution files',type=str, default='../skew-aware-bpk-benchmark/output-stats/')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/cdf.pdf')
    parser.add_argument('--showLegend', action='store_true', help='show the legend')
    parser.add_argument('--legendLoc',help='the location of the legend', default='lower right')
    args = parser.parse_args()
    main(args)
