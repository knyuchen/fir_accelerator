from fix_point import *
from bin_hex import *

def cross_fp (input_list, filter_fir, shift):
   out = []
   input_list = input_list + (len(filter_fir) - 1)*[0]
   for i in range (len(input_list)) :
      psum = 0
      if i < len(filter_fir) - 1:
         for j in range (i+1):
            temp = mult_fp(input_list[i-j], filter_fir[j],  1, shift)
            psum = add_fp(psum, temp)
      else:
         for j in range (len(filter_fir)):
            temp = mult_fp(input_list [i - j], filter_fir[j], 1, shift)
            psum = add_fp(psum, temp)

      out.append(psum)
   return out




