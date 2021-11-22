from fix_point import *
from bin_hex import *
input_list = []

def auto_fp (input_list, delay, filter_size, shift):
   input_list = input_list + (filter_size - 1) * [0]
   delay_list = [0]*delay + input_list[:(-1)*delay]


   mult_list = []

#   for i in range (delay, len(input_list)):
   for i in range (len(input_list)):
      mult_list.append(mult_fp(input_list[i], delay_list[i], 1, shift))

#   print(mult_list)

   out = []

#   for i in range (len(input_list) - delay) :
   for i in range (len(input_list)) :
      psum = 0
      if i < filter_size - 1:
         for j in range (i+1):
            psum = add_fp(psum, mult_list[j])
      else:
         for j in range (filter_size):
            psum = add_fp(psum, mult_list[i-j])

      out.append(psum)

   return out


