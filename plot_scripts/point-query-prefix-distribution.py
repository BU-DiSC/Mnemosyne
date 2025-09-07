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


def print_progress_bar(iteration, total, length=50):
  percent = ("{0:.1f}").format(100 * (iteration / float(total)))
  filled_length = int(length * iteration // total)
  bar = '█' * filled_length + '-' * (length - filled_length)
  sys.stdout.write(f'\rProgress: |{bar}| {percent}% Complete')
  sys.stdout.flush()
  if iteration >= total:
      sys.stdout.write('\n')

# Take 13 minutes to load 15M keys
def write_for_file(fname):
  print("Processing " + fname)
  df = pd.read_csv(fname, header = None, sep = " ")
  # df[0] are operation types
  # We take the first three characters
  y = [0 for _ in range(len(df[1]))]
  prefix_to_cnt = dict()
  for i in range(len(df[1])):
      num = charToValue(df[1][i][:2])
      if num in prefix_to_cnt:
          prefix_to_cnt[num] += 1
      else:
          prefix_to_cnt[num] = 1
      print_progress_bar(i+1, len(df[1]))

  item = list(prefix_to_cnt.items())
  item.sort()
  x_ = []
  y_ = []


  # Merging two bins into one
  for i in range(len(item)//2):
      x_.append((item[i*2][0] + item[i*2+1][0])//2)
      y_.append(item[i*2][1] + item[i*2+1][1])
  if len(item)%2 != 0:
      # No bin to merge for the last one
      x_.append(item[-1][0])
      y_.append(item[-1][1]*2)

  # print(fname)
  # print(y_)
  return (x_, y_)

base62_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

char_to_value = {char: index for index, char in enumerate(base62_chars)}

def charToValue(str1):
  base = len(base62_chars)
  str1 = str(str1)
  if(str1 == "null"):
   return 0
  # print(str(str))
  ret = 0 
  for ch in str1:
    # We do not aim to produce one-to-one mapping, so we adjust the base to shrink the key space return ret
    if ret != 0:
        ret = ret * base + char_to_value[ch] // 2
    else:
        ret = (char_to_value[ch] // 2)
  return ret



def main(args):
    
    distributions = [
        ['Normal_Dis_NDEV3.0', 'brown' , 'dashed', 'Normal $(\sigma = 3.0)$'],
        ['Normal_Dis_NDEV4.0', 'gray', 'dashdot', 'Normal $(\sigma = 4.0)$'],
        ['Normal_Dis_NDEV5.0', 'orange', 'dotted', 'Normal $(\sigma = 5.0)$'],
        ['Uniform_Dis', 'black', 'solid', 'Uniform'],
    ]
    # ax = axes[0]
    fig, ax = plt.subplots(1, 1, figsize=(10,6))
    for partial_path, color, linestyle, label in distributions:
      (x, y) = write_for_file(args.prefix_path + "/" + partial_path + "_empty_query_workload.txt")
      # print(x)
      # print(y)
      ax.plot(x, y, color=color, label=label, linestyle=linestyle,linewidth=3)
      
    if args.showLegend:
      ax.legend(loc=args.legendLoc, ncols=1, columnspacing=0.3, labelspacing=0.2,fontsize=fontsize-6,borderaxespad=0.1)
    
    ax.set_yticks(ticks = [0, 50000, 100000, 150000])
    ax.set_yticklabels(['0', '5','10', '15'])
    #ax.set_yticks(ticks = [0, 50000, 100000, 150000])
    ax.set_xticks(ticks=[x[int(i*(len(x) - 1)/5)] for i in range(6)])
    ax.set_xticklabels([f'{i*0.2:.1f}' for i in range(6)])
    ax.set_ylabel(r'Frequency ($\times 10^4$)', fontsize = fontsize - 2)
    ax.set_xlabel('Key Space', fontsize = fontsize - 2)
    
    #plt.show()
    plt.tight_layout()
    fig.savefig(args.name, bbox_inches = "tight", dpi=900)
            

if __name__ == "__main__":
    parser = argparse.ArgumentParser('vary-point-query-distribution-plot')
    parser.add_argument('--prefix_path',help='prefix path of distribution files',type=str, default='../workload_generator_scripts/')
    parser.add_argument('--name',help='name of the plot', default='../exp-figures/prefix-distribution.pdf')
    parser.add_argument('--showLegend', action='store_true', help='show the legend')
    parser.add_argument('--legendLoc',help='the location of the legend', default='upper right')
    args = parser.parse_args()
    main(args)
