def up_sampling (in_list, rate):
   out = []
   for i in range (len(in_list)):
      out.append(in_list[i])
      out = out + rate * [0]
   return out

def down_sampling (in_list, rate):
   out = []
   for i in range (len(in_list)):
      if i % rate == 0:
         out.append(in_list[i])
   return out
